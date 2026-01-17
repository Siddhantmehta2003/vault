from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from pydantic import BaseModel, EmailStr
from typing import Optional
import secrets

from ..services.email_service import email_service
from ..dependencies import get_current_user
from ..models import UserInDB

router = APIRouter(prefix="/email", tags=["Email"])


class SendTestEmailRequest(BaseModel):
    """Request to send test email"""
    to: EmailStr
    

class SendVerificationRequest(BaseModel):
    """Request to send verification email"""
    email: EmailStr
    username: str


class VerifyCodeRequest(BaseModel):
    """Request to verify email code"""
    email: EmailStr
    code: str


class EmailResponse(BaseModel):
    """Email send response"""
    success: bool
    message: str
    email_id: Optional[str] = None


# In-memory storage for verification codes (in production, use Redis or database)
verification_codes: dict = {}


def generate_verification_code() -> str:
    """Generate a 6-digit verification code"""
    return ''.join([str(secrets.randbelow(10)) for _ in range(6)])


@router.post("/test", response_model=EmailResponse)
async def send_test_email(request: SendTestEmailRequest):
    """
    Send a test email to verify the email service is working
    """
    result = email_service._send_email(
        to=request.to,
        subject="Test Email from Vault",
        html="""
        <div style="font-family: Arial, sans-serif; padding: 20px;">
            <h1 style="color: #7c3aed;">🎉 Test Email Successful!</h1>
            <p>Congratulations! Your email service is configured correctly.</p>
            <p>This email was sent from <strong>Vault Password Manager</strong>.</p>
            <hr style="border: 1px solid #e4e4e7; margin: 20px 0;">
            <p style="color: #71717a; font-size: 12px;">
                If you received this email, your Resend integration is working properly.
            </p>
        </div>
        """
    )
    
    if result["success"]:
        return EmailResponse(
            success=True,
            message=f"Test email sent successfully to {request.to}",
            email_id=result.get("id")
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send email: {result.get('error')}"
        )


@router.post("/send-verification", response_model=EmailResponse)
async def send_verification_email(
    request: SendVerificationRequest,
    background_tasks: BackgroundTasks
):
    """
    Send email verification code to user
    """
    # Generate verification code
    code = generate_verification_code()
    
    # Store code (expires in 15 minutes - in production use Redis with TTL)
    verification_codes[request.email] = {
        "code": code,
        "username": request.username
    }
    
    # Send email
    result = email_service.send_verification_email(
        to=request.email,
        username=request.username,
        verification_code=code
    )
    
    if result["success"]:
        return EmailResponse(
            success=True,
            message="Verification code sent successfully",
            email_id=result.get("id")
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send verification email: {result.get('error')}"
        )


@router.post("/verify-code", response_model=EmailResponse)
async def verify_email_code(request: VerifyCodeRequest):
    """
    Verify the email verification code
    """
    stored = verification_codes.get(request.email)
    
    if not stored:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No verification code found for this email. Please request a new code."
        )
    
    if stored["code"] != request.code:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid verification code"
        )
    
    # Remove used code
    del verification_codes[request.email]
    
    return EmailResponse(
        success=True,
        message="Email verified successfully"
    )


@router.post("/send-welcome", response_model=EmailResponse)
async def send_welcome_email(
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Send welcome email to the authenticated user
    """
    result = email_service.send_welcome_email(
        to=current_user.email,
        username=current_user.username,
        first_name=current_user.first_name or current_user.username
    )
    
    if result["success"]:
        return EmailResponse(
            success=True,
            message="Welcome email sent successfully",
            email_id=result.get("id")
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send welcome email: {result.get('error')}"
        )


@router.post("/send-password-reset", response_model=EmailResponse)
async def send_password_reset_email(request: SendVerificationRequest):
    """
    Send password reset code to user
    """
    # Generate reset code
    code = generate_verification_code()
    
    # Store code
    verification_codes[f"reset_{request.email}"] = {
        "code": code,
        "username": request.username
    }
    
    result = email_service.send_password_reset_email(
        to=request.email,
        username=request.username,
        reset_code=code
    )
    
    if result["success"]:
        return EmailResponse(
            success=True,
            message="Password reset code sent successfully",
            email_id=result.get("id")
        )
    else:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to send password reset email: {result.get('error')}"
        )

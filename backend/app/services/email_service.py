import resend
import logging
from typing import Optional, List, Dict, Any
from datetime import datetime
from ..config import settings

logger = logging.getLogger(__name__)


class EmailService:
    """Email service using Resend for sending transactional emails"""
    
    def __init__(self):
        resend.api_key = settings.resend_api_key
        self.from_email = settings.email_from
        self.app_name = "Vault"
    
    def _send_email(
        self,
        to: str | List[str],
        subject: str,
        html: str,
        text: Optional[str] = None
    ) -> Dict[str, Any]:
        """Base method to send email"""
        try:
            params = {
                "from": self.from_email,
                "to": to if isinstance(to, list) else [to],
                "subject": subject,
                "html": html,
            }
            if text:
                params["text"] = text
            
            response = resend.Emails.send(params)
            logger.info(f"Email sent successfully to {to}: {subject}")
            return {"success": True, "id": response.get("id")}
        except Exception as e:
            logger.error(f"Failed to send email to {to}: {e}")
            return {"success": False, "error": str(e)}
    
    def send_welcome_email(self, to: str, username: str, first_name: str) -> Dict[str, Any]:
        """Send welcome email after registration"""
        subject = f"Welcome to {self.app_name} - Your Secure Password Manager"
        html = self._get_welcome_template(username, first_name)
        return self._send_email(to, subject, html)
    
    def send_verification_email(self, to: str, username: str, verification_code: str) -> Dict[str, Any]:
        """Send email verification code"""
        subject = f"Verify your {self.app_name} account"
        html = self._get_verification_template(username, verification_code)
        return self._send_email(to, subject, html)
    
    def send_password_reset_email(self, to: str, username: str, reset_code: str) -> Dict[str, Any]:
        """Send password reset code"""
        subject = f"Reset your {self.app_name} password"
        html = self._get_password_reset_template(username, reset_code)
        return self._send_email(to, subject, html)
    
    def send_login_alert_email(self, to: str, username: str, device: str, location: str, ip: str) -> Dict[str, Any]:
        """Send login alert notification"""
        subject = f"New login to your {self.app_name} account"
        html = self._get_login_alert_template(username, device, location, ip)
        return self._send_email(to, subject, html)
    
    def send_password_changed_email(self, to: str, username: str) -> Dict[str, Any]:
        """Send notification when password is changed"""
        subject = f"Your {self.app_name} password was changed"
        html = self._get_password_changed_template(username)
        return self._send_email(to, subject, html)
    
    def send_security_alert_email(self, to: str, username: str, alert_type: str, details: str) -> Dict[str, Any]:
        """Send security alert"""
        subject = f"Security Alert - {self.app_name}"
        html = self._get_security_alert_template(username, alert_type, details)
        return self._send_email(to, subject, html)
    
    def send_bulk_emails(self, recipients: List[Dict[str, str]], subject: str, html: str) -> List[Dict[str, Any]]:
        """Send same email to multiple recipients"""
        results = []
        for recipient in recipients:
            result = self._send_email(recipient["email"], subject, html)
            result["recipient"] = recipient["email"]
            results.append(result)
        return results
    
    # ==================== Email Templates ====================
    
    def _get_base_template(self, content: str) -> str:
        """Base HTML template wrapper"""
        return f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{self.app_name}</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f5;">
    <table role="presentation" style="width: 100%; border-collapse: collapse;">
        <tr>
            <td align="center" style="padding: 40px 0;">
                <table role="presentation" style="width: 600px; border-collapse: collapse; background-color: #ffffff; border-radius: 16px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 40px 40px 20px 40px; text-align: center; background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); border-radius: 16px 16px 0 0;">
                            <div style="width: 60px; height: 60px; background-color: rgba(255,255,255,0.2); border-radius: 50%; margin: 0 auto 16px auto; display: flex; align-items: center; justify-content: center;">
                                <span style="font-size: 28px;">🔐</span>
                            </div>
                            <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 700;">{self.app_name}</h1>
                            <p style="color: rgba(255,255,255,0.8); margin: 8px 0 0 0; font-size: 14px;">Secure Password Manager</p>
                        </td>
                    </tr>
                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px;">
                            {content}
                        </td>
                    </tr>
                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px 40px 40px 40px; text-align: center; border-top: 1px solid #e4e4e7;">
                            <p style="color: #71717a; font-size: 12px; margin: 0;">
                                This email was sent by {self.app_name}. If you didn't request this email, please ignore it.
                            </p>
                            <p style="color: #a1a1aa; font-size: 11px; margin: 16px 0 0 0;">
                                © {datetime.now().year} {self.app_name}. All rights reserved.
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>
"""
    
    def _get_welcome_template(self, username: str, first_name: str) -> str:
        """Welcome email template"""
        content = f"""
            <h2 style="color: #18181b; margin: 0 0 16px 0; font-size: 24px;">Welcome, {first_name}! 🎉</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Thank you for joining <strong>{self.app_name}</strong>! Your account has been created successfully.
            </p>
            <div style="background-color: #faf5ff; border-radius: 12px; padding: 24px; margin-bottom: 24px;">
                <p style="color: #7c3aed; font-weight: 600; margin: 0 0 8px 0;">Your Account Details:</p>
                <p style="color: #3f3f46; margin: 0;"><strong>Username:</strong> {username}</p>
            </div>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                With {self.app_name}, you can securely store and manage all your passwords in one place. Here's what you can do:
            </p>
            <ul style="color: #3f3f46; font-size: 14px; line-height: 1.8; padding-left: 20px; margin: 0 0 24px 0;">
                <li>Store unlimited passwords securely</li>
                <li>Access your vault from any device</li>
                <li>Generate strong, unique passwords</li>
                <li>Organize passwords by categories</li>
            </ul>
            <div style="text-align: center;">
                <a href="#" style="display: inline-block; background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 16px;">Get Started</a>
            </div>
"""
        return self._get_base_template(content)
    
    def _get_verification_template(self, username: str, verification_code: str) -> str:
        """Email verification template"""
        content = f"""
            <h2 style="color: #18181b; margin: 0 0 16px 0; font-size: 24px;">Verify Your Email</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi <strong>{username}</strong>,<br><br>
                Please use the verification code below to verify your email address and complete your account setup.
            </p>
            <div style="background: linear-gradient(135deg, #7c3aed 0%, #a855f7 100%); border-radius: 12px; padding: 32px; text-align: center; margin-bottom: 24px;">
                <p style="color: rgba(255,255,255,0.8); margin: 0 0 8px 0; font-size: 14px;">Your Verification Code</p>
                <p style="color: #ffffff; font-size: 36px; font-weight: 700; letter-spacing: 8px; margin: 0;">{verification_code}</p>
            </div>
            <div style="background-color: #fef3c7; border-radius: 8px; padding: 16px; margin-bottom: 24px;">
                <p style="color: #92400e; font-size: 14px; margin: 0;">
                    ⚠️ This code will expire in <strong>15 minutes</strong>. Do not share this code with anyone.
                </p>
            </div>
            <p style="color: #71717a; font-size: 14px; line-height: 1.6; margin: 0;">
                If you didn't create an account with {self.app_name}, you can safely ignore this email.
            </p>
"""
        return self._get_base_template(content)
    
    def _get_password_reset_template(self, username: str, reset_code: str) -> str:
        """Password reset email template"""
        content = f"""
            <h2 style="color: #18181b; margin: 0 0 16px 0; font-size: 24px;">Reset Your Password</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi <strong>{username}</strong>,<br><br>
                We received a request to reset your password. Use the code below to create a new password.
            </p>
            <div style="background: linear-gradient(135deg, #dc2626 0%, #f87171 100%); border-radius: 12px; padding: 32px; text-align: center; margin-bottom: 24px;">
                <p style="color: rgba(255,255,255,0.8); margin: 0 0 8px 0; font-size: 14px;">Your Reset Code</p>
                <p style="color: #ffffff; font-size: 36px; font-weight: 700; letter-spacing: 8px; margin: 0;">{reset_code}</p>
            </div>
            <div style="background-color: #fee2e2; border-radius: 8px; padding: 16px; margin-bottom: 24px;">
                <p style="color: #991b1b; font-size: 14px; margin: 0;">
                    🔒 This code expires in <strong>10 minutes</strong>. If you didn't request a password reset, please secure your account immediately.
                </p>
            </div>
"""
        return self._get_base_template(content)
    
    def _get_login_alert_template(self, username: str, device: str, location: str, ip: str) -> str:
        """Login alert email template"""
        content = f"""
            <h2 style="color: #18181b; margin: 0 0 16px 0; font-size: 24px;">New Login Detected</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi <strong>{username}</strong>,<br><br>
                We detected a new login to your {self.app_name} account.
            </p>
            <div style="background-color: #f4f4f5; border-radius: 12px; padding: 24px; margin-bottom: 24px;">
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #71717a; font-size: 14px;">Device:</td>
                        <td style="padding: 8px 0; color: #18181b; font-size: 14px; font-weight: 600; text-align: right;">{device}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #71717a; font-size: 14px;">Location:</td>
                        <td style="padding: 8px 0; color: #18181b; font-size: 14px; font-weight: 600; text-align: right;">{location}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #71717a; font-size: 14px;">IP Address:</td>
                        <td style="padding: 8px 0; color: #18181b; font-size: 14px; font-weight: 600; text-align: right;">{ip}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #71717a; font-size: 14px;">Time:</td>
                        <td style="padding: 8px 0; color: #18181b; font-size: 14px; font-weight: 600; text-align: right;">{datetime.now().strftime('%B %d, %Y at %I:%M %p')}</td>
                    </tr>
                </table>
            </div>
            <p style="color: #3f3f46; font-size: 14px; line-height: 1.6; margin: 0 0 24px 0;">
                If this was you, no action is needed. If you don't recognize this activity, please change your password immediately.
            </p>
            <div style="text-align: center;">
                <a href="#" style="display: inline-block; background-color: #dc2626; color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 14px;">Secure My Account</a>
            </div>
"""
        return self._get_base_template(content)
    
    def _get_password_changed_template(self, username: str) -> str:
        """Password changed notification template"""
        content = f"""
            <h2 style="color: #18181b; margin: 0 0 16px 0; font-size: 24px;">Password Changed Successfully</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi <strong>{username}</strong>,<br><br>
                Your {self.app_name} password was successfully changed on <strong>{datetime.now().strftime('%B %d, %Y at %I:%M %p')}</strong>.
            </p>
            <div style="background-color: #dcfce7; border-radius: 8px; padding: 16px; margin-bottom: 24px;">
                <p style="color: #166534; font-size: 14px; margin: 0;">
                    ✅ Your account is secure. You can now use your new password to log in.
                </p>
            </div>
            <p style="color: #71717a; font-size: 14px; line-height: 1.6; margin: 0;">
                If you didn't make this change, please contact our support team immediately.
            </p>
"""
        return self._get_base_template(content)
    
    def _get_security_alert_template(self, username: str, alert_type: str, details: str) -> str:
        """Security alert template"""
        content = f"""
            <h2 style="color: #dc2626; margin: 0 0 16px 0; font-size: 24px;">⚠️ Security Alert</h2>
            <p style="color: #3f3f46; font-size: 16px; line-height: 1.6; margin: 0 0 24px 0;">
                Hi <strong>{username}</strong>,<br><br>
                We detected suspicious activity on your {self.app_name} account.
            </p>
            <div style="background-color: #fee2e2; border-radius: 12px; padding: 24px; margin-bottom: 24px; border-left: 4px solid #dc2626;">
                <p style="color: #991b1b; font-weight: 600; margin: 0 0 8px 0;">{alert_type}</p>
                <p style="color: #7f1d1d; font-size: 14px; margin: 0;">{details}</p>
            </div>
            <p style="color: #3f3f46; font-size: 14px; line-height: 1.6; margin: 0 0 24px 0;">
                We recommend taking the following actions:
            </p>
            <ul style="color: #3f3f46; font-size: 14px; line-height: 1.8; padding-left: 20px; margin: 0 0 24px 0;">
                <li>Change your password immediately</li>
                <li>Enable two-factor authentication</li>
                <li>Review your recent account activity</li>
            </ul>
            <div style="text-align: center;">
                <a href="#" style="display: inline-block; background-color: #dc2626; color: #ffffff; text-decoration: none; padding: 14px 32px; border-radius: 8px; font-weight: 600; font-size: 14px;">Secure My Account</a>
            </div>
"""
        return self._get_base_template(content)


# Create singleton instance
email_service = EmailService()

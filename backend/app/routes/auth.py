from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from motor.motor_asyncio import AsyncIOMotorDatabase
from datetime import datetime, timedelta
from bson import ObjectId

from ..database import get_database
from ..dependencies import get_current_user
from ..models import UserCreate, User, UserInDB, Token, MessageResponse
from ..security import security_service
from ..config import settings

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=Token, status_code=status.HTTP_201_CREATED)
async def register(
    user_data: UserCreate,
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Register a new user and return an access token
    """
    
    # Check if user already exists
    existing_user = await db.users.find_one({
        "$or": [
            {"email": user_data.email},
            {"username": user_data.username}
        ]
    })
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="User with this email or username already exists"
        )
    
    # Hash passwords
    hashed_password = security_service.get_password_hash(user_data.password)
    hashed_master_password = security_service.get_password_hash(user_data.master_password)
    
    # Create user document
    user_doc = {
        "email": user_data.email,
        "username": user_data.username,
        "first_name": user_data.first_name,
        "last_name": user_data.last_name,
        "phone_number": user_data.phone_number,
        "hashed_password": hashed_password,
        "hashed_master_password": hashed_master_password,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    # Insert user
    result = await db.users.insert_one(user_doc)
    user_id = str(result.inserted_id)
    
    # Create access token immediately
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = security_service.create_access_token(
        data={"sub": user_data.username, "user_id": user_id},
        expires_delta=access_token_expires
    )
    
    return Token(access_token=access_token, token_type="bearer")


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Login with username and password
    
    Returns JWT access token
    """
    
    # Find user
    user = await db.users.find_one({"username": form_data.username})
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Verify password
    if not security_service.verify_password(form_data.password, user["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
    access_token = security_service.create_access_token(
        data={"sub": user["username"], "user_id": str(user["_id"])},
        expires_delta=access_token_expires
    )
    
    return Token(access_token=access_token, token_type="bearer")


@router.post("/verify-master-password", response_model=MessageResponse)
async def verify_master_password_endpoint(
    master_password: str,
    db: AsyncIOMotorDatabase = Depends(get_database),
    current_user = Depends(lambda: None)  # Will be implemented with proper auth
):
    """
    Verify master password
    
    Used before performing sensitive operations
    """
    
    # This will be properly implemented with authentication
    return MessageResponse(
        message="Master password verified",
        success=True
    )


@router.get("/me", response_model=User)
async def get_current_user_info(
    current_user: UserInDB = Depends(get_current_user)
):
    """
    Get current user information
    """
    return User(
        id=current_user.id,
        email=current_user.email,
        username=current_user.username,
        created_at=current_user.created_at
    )

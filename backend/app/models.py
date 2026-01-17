from pydantic import BaseModel, Field, EmailStr, ConfigDict, field_validator, AfterValidator
from typing import Optional, Any, Annotated
from datetime import datetime
from bson import ObjectId


def validate_object_id(v: Any) -> str:
    if isinstance(v, ObjectId):
        return str(v)
    if not ObjectId.is_valid(v):
        raise ValueError("Invalid ObjectId")
    return str(v)

PyObjectId = Annotated[str, AfterValidator(validate_object_id)]


# User Models
class UserBase(BaseModel):
    """Base user model"""
    email: EmailStr
    username: str


class UserCreate(UserBase):
    """User creation model"""
    first_name: str
    last_name: str
    phone_number: Optional[str] = None
    password: str
    master_password: str


class UserLogin(BaseModel):
    """User login model"""
    username: str
    password: str


class UserInDB(UserBase):
    """User model as stored in database"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: PyObjectId = Field(alias="_id")
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    hashed_password: str
    hashed_master_password: str
    created_at: datetime
    updated_at: datetime


class User(UserBase):
    """User response model"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: str
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_number: Optional[str] = None
    created_at: datetime


# Password Entry Models
class PasswordBase(BaseModel):
    """Base password entry model"""
    title: str
    username: str
    password: str
    url: Optional[str] = ""
    notes: Optional[str] = ""
    category: str = "Personal"


class PasswordCreate(PasswordBase):
    """Password creation model"""
    pass


class PasswordUpdate(BaseModel):
    """Password update model"""
    title: Optional[str] = None
    username: Optional[str] = None
    password: Optional[str] = None
    url: Optional[str] = None
    notes: Optional[str] = None
    category: Optional[str] = None


class PasswordInDB(PasswordBase):
    """Password model as stored in database"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: PyObjectId = Field(alias="_id")
    user_id: str
    encrypted_password: str
    created_at: datetime
    updated_at: datetime


class Password(BaseModel):
    """Password response model"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: str
    title: str
    username: str
    password: str  # Decrypted password
    url: str
    notes: str
    category: str
    created_at: datetime
    updated_at: datetime


# Token Models
class Token(BaseModel):
    """JWT token model"""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Token payload data"""
    username: Optional[str] = None
    user_id: Optional[str] = None


# Response Models
class MessageResponse(BaseModel):
    """Generic message response"""
    message: str
    success: bool = True


class PasswordListResponse(BaseModel):
    """Password list response"""
    passwords: list[Password]
    total: int

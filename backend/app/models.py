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
    
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
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
    shared_vault_id: Optional[str] = None



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
    shared_vault_id: Optional[str] = None



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
    shared_vault_id: Optional[str] = None

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


# Team Models
class TeamMember(BaseModel):
    """Team member model"""
    user_id: str
    role: str = "Viewer"  # Admin, Editor, Viewer
    joined_at: datetime = Field(default_factory=datetime.utcnow)


class TeamBase(BaseModel):
    """Base team model"""
    name: str


class TeamCreate(TeamBase):
    """Team creation model"""
    pass


class TeamInDB(TeamBase):
    """Team model as stored in database"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    code: str
    created_by: str
    members: list[TeamMember]
    created_at: datetime
    updated_at: datetime



class Team(TeamBase):
    """Team response model"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: str
    code: str
    created_by: str
    role: Optional[str] = None  # Current user's role
    member_count: int
    created_at: datetime


# Shared Vault Models
class SharedVaultBase(BaseModel):
    """Base shared vault model"""
    name: str



class SharedVaultCreate(SharedVaultBase):
    """Shared vault creation model"""
    member_ids: list[str] = []


class SharedVaultInDB(SharedVaultBase):
    """Shared vault model as stored in database"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    team_id: str
    created_by: str
    member_ids: list[str]
    created_at: datetime
    updated_at: datetime



class SharedVault(SharedVaultBase):
    """Shared vault response model"""
    model_config = ConfigDict(
        populate_by_name=True,
        arbitrary_types_allowed=True,
        json_encoders={ObjectId: str}
    )
    
    id: str
    team_id: str
    created_by: str
    member_ids: list[str]
    password_count: int = 0
    created_at: datetime


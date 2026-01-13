from fastapi import APIRouter, Depends, HTTPException, status, Header
from motor.motor_asyncio import AsyncIOMotorDatabase
from typing import List, Optional
from datetime import datetime
from bson import ObjectId

from ..database import get_database
from ..models import (
    PasswordCreate, 
    Password, 
    PasswordUpdate, 
    MessageResponse,
    PasswordListResponse,
    UserInDB
)
from ..dependencies import get_current_user
from ..security import EncryptionService, security_service

router = APIRouter(prefix="/passwords", tags=["Passwords"])


@router.post("/", response_model=Password, status_code=status.HTTP_201_CREATED)
async def create_password(
    password_data: PasswordCreate,
    master_password: str = Header(..., alias="X-Master-Password"),
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Create a new password entry
    
    Requires master password in X-Master-Password header
    """
    
    # Verify master password
    if not security_service.verify_password(master_password, current_user.hashed_master_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid master password"
        )
    
    # Encrypt password
    encryption_service = EncryptionService(master_password)
    encrypted_password = encryption_service.encrypt_password(password_data.password)
    
    # Create password document
    password_doc = {
        "user_id": current_user.id,
        "title": password_data.title,
        "username": password_data.username,
        "encrypted_password": encrypted_password,
        "url": password_data.url or "",
        "notes": password_data.notes or "",
        "category": password_data.category,
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow()
    }
    
    # Insert password
    result = await db.passwords.insert_one(password_doc)
    
    # Return password with decrypted password
    return Password(
        id=str(result.inserted_id),
        title=password_data.title,
        username=password_data.username,
        password=password_data.password,  # Return original password
        url=password_data.url or "",
        notes=password_data.notes or "",
        category=password_data.category,
        created_at=password_doc["created_at"],
        updated_at=password_doc["updated_at"]
    )


@router.get("/", response_model=PasswordListResponse)
async def get_passwords(
    master_password: str = Header(..., alias="X-Master-Password"),
    category: Optional[str] = None,
    search: Optional[str] = None,
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get all passwords for current user
    
    Requires master password in X-Master-Password header
    Optional filters: category, search (searches in title and username)
    """
    
    # Verify master password
    if not security_service.verify_password(master_password, current_user.hashed_master_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid master password"
        )
    
    # Build query
    query = {"user_id": current_user.id}
    
    if category:
        query["category"] = category
    
    if search:
        query["$or"] = [
            {"title": {"$regex": search, "$options": "i"}},
            {"username": {"$regex": search, "$options": "i"}}
        ]
    
    # Get passwords
    cursor = db.passwords.find(query).sort("created_at", -1)
    passwords_docs = await cursor.to_list(length=None)
    
    # Decrypt passwords
    encryption_service = EncryptionService(master_password)
    passwords = []
    
    for doc in passwords_docs:
        try:
            decrypted_password = encryption_service.decrypt_password(doc["encrypted_password"])
            passwords.append(Password(
                id=str(doc["_id"]),
                title=doc["title"],
                username=doc["username"],
                password=decrypted_password,
                url=doc.get("url", ""),
                notes=doc.get("notes", ""),
                category=doc["category"],
                created_at=doc["created_at"],
                updated_at=doc["updated_at"]
            ))
        except Exception as e:
            # Skip passwords that can't be decrypted
            continue
    
    return PasswordListResponse(
        passwords=passwords,
        total=len(passwords)
    )


@router.get("/{password_id}", response_model=Password)
async def get_password(
    password_id: str,
    master_password: str = Header(..., alias="X-Master-Password"),
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get a specific password by ID
    
    Requires master password in X-Master-Password header
    """
    
    # Verify master password
    if not security_service.verify_password(master_password, current_user.hashed_master_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid master password"
        )
    
    # Validate ObjectId
    if not ObjectId.is_valid(password_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password ID"
        )
    
    # Get password
    password_doc = await db.passwords.find_one({
        "_id": ObjectId(password_id),
        "user_id": current_user.id
    })
    
    if not password_doc:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Password not found"
        )
    
    # Decrypt password
    encryption_service = EncryptionService(master_password)
    decrypted_password = encryption_service.decrypt_password(password_doc["encrypted_password"])
    
    return Password(
        id=str(password_doc["_id"]),
        title=password_doc["title"],
        username=password_doc["username"],
        password=decrypted_password,
        url=password_doc.get("url", ""),
        notes=password_doc.get("notes", ""),
        category=password_doc["category"],
        created_at=password_doc["created_at"],
        updated_at=password_doc["updated_at"]
    )


@router.put("/{password_id}", response_model=Password)
async def update_password(
    password_id: str,
    password_data: PasswordUpdate,
    master_password: str = Header(..., alias="X-Master-Password"),
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Update a password entry
    
    Requires master password in X-Master-Password header
    """
    
    # Verify master password
    if not security_service.verify_password(master_password, current_user.hashed_master_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid master password"
        )
    
    # Validate ObjectId
    if not ObjectId.is_valid(password_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password ID"
        )
    
    # Get existing password
    existing_password = await db.passwords.find_one({
        "_id": ObjectId(password_id),
        "user_id": current_user.id
    })
    
    if not existing_password:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Password not found"
        )
    
    # Build update document
    update_doc = {"updated_at": datetime.utcnow()}
    
    if password_data.title is not None:
        update_doc["title"] = password_data.title
    if password_data.username is not None:
        update_doc["username"] = password_data.username
    if password_data.url is not None:
        update_doc["url"] = password_data.url
    if password_data.notes is not None:
        update_doc["notes"] = password_data.notes
    if password_data.category is not None:
        update_doc["category"] = password_data.category
    
    # Encrypt new password if provided
    if password_data.password is not None:
        encryption_service = EncryptionService(master_password)
        update_doc["encrypted_password"] = encryption_service.encrypt_password(password_data.password)
    
    # Update password
    await db.passwords.update_one(
        {"_id": ObjectId(password_id)},
        {"$set": update_doc}
    )
    
    # Get updated password
    updated_password = await db.passwords.find_one({"_id": ObjectId(password_id)})
    
    # Decrypt password
    encryption_service = EncryptionService(master_password)
    decrypted_password = encryption_service.decrypt_password(updated_password["encrypted_password"])
    
    return Password(
        id=str(updated_password["_id"]),
        title=updated_password["title"],
        username=updated_password["username"],
        password=decrypted_password,
        url=updated_password.get("url", ""),
        notes=updated_password.get("notes", ""),
        category=updated_password["category"],
        created_at=updated_password["created_at"],
        updated_at=updated_password["updated_at"]
    )


@router.delete("/{password_id}", response_model=MessageResponse)
async def delete_password(
    password_id: str,
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Delete a password entry
    """
    
    # Validate ObjectId
    if not ObjectId.is_valid(password_id):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid password ID"
        )
    
    # Delete password
    result = await db.passwords.delete_one({
        "_id": ObjectId(password_id),
        "user_id": current_user.id
    })
    
    if result.deleted_count == 0:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Password not found"
        )
    
    return MessageResponse(
        message="Password deleted successfully",
        success=True
    )


@router.get("/categories/list", response_model=List[str])
async def get_categories(
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncIOMotorDatabase = Depends(get_database)
):
    """
    Get list of all unique categories for current user
    """
    
    categories = await db.passwords.distinct("category", {"user_id": current_user.id})
    return categories

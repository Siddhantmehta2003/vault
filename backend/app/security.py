from datetime import datetime, timedelta
from typing import Optional, Any
from jose import JWTError, jwt
from passlib.context import CryptContext
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.backends import default_backend
import base64
import hashlib
from .config import settings

# Use PBKDF2 with SHA256 - no 72 byte limit and very secure
pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")


class SecurityService:
    """Security service for password hashing, JWT tokens, and encryption"""
    
    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        """Verify a plain password against a hashed password"""
        if not plain_password:
            return False
        return pwd_context.verify(plain_password, hashed_password)
    
    def get_password_hash(self, password: str) -> str:
        """Hash a password"""
        if not password:
            raise ValueError("Password cannot be blank")
        return pwd_context.hash(password)
    
    @staticmethod
    def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
        """Create a JWT access token"""
        to_encode = data.copy()
        
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
        
        to_encode.update({"exp": expire})
        encoded_jwt = jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)
        return encoded_jwt
    
    @staticmethod
    def decode_access_token(token: str) -> Optional[dict]:
        """Decode and verify a JWT token"""
        try:
            payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
            return payload
        except JWTError:
            return None


class EncryptionService:
    """Service for encrypting and decrypting passwords"""
    
    def __init__(self, master_password: str):
        """Initialize encryption service with master password"""
        self.master_password = master_password
        self._fernet = None
    
    def _get_fernet(self) -> Fernet:
        """Get or create Fernet cipher"""
        if self._fernet is None:
            # Derive key from master password
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=b'password_manager_salt',
                iterations=100000,
                backend=default_backend()
            )
            key = base64.urlsafe_b64encode(kdf.derive(self.master_password.encode()))
            self._fernet = Fernet(key)
        return self._fernet
    
    def encrypt_password(self, password: str) -> str:
        """Encrypt a password"""
        fernet = self._get_fernet()
        encrypted = fernet.encrypt(password.encode())
        return base64.urlsafe_b64encode(encrypted).decode()
    
    def decrypt_password(self, encrypted_password: str) -> str:
        """Decrypt a password"""
        try:
            fernet = self._get_fernet()
            decoded = base64.urlsafe_b64decode(encrypted_password.encode())
            decrypted = fernet.decrypt(decoded)
            return decrypted.decode()
        except Exception as e:
            raise ValueError(f"Failed to decrypt password: {str(e)}")
    
    @staticmethod
    def generate_encryption_key() -> str:
        """Generate a new encryption key"""
        return Fernet.generate_key().decode()


# Create security service instance
security_service = SecurityService()

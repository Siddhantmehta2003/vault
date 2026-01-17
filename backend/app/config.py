from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import Optional, List


class Settings(BaseSettings):
    """Application settings and configuration"""
    
    # MongoDB Atlas settings
    mongodb_url: str = "mongodb://localhost:27017"
    mongodb_uri: Optional[str] = None  # Alternative env var name
    database_name: str = "password_manager"
    
    # Security settings
    secret_key: str = "09d25e094faa6ca2556c818166b7a9563b93f7099f6f0f4caa6cf63b88e8d3e7"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    
    # Encryption key for passwords (32 bytes for AES-256)
    encryption_key: str = "your-32-byte-encryption-key-here"
    
    # Email settings (Resend)
    resend_api_key: str = "re_iM1PeVEe_F1wb5AnuJfJnb2XuucgsPER3"
    email_from: str = "Vault <onboarding@resend.dev>"
    
    # CORS settings (as string, will be split)
    cors_origins_str: str = "*"
    
    @property
    def cors_origins(self) -> List[str]:
        """Parse CORS origins from string"""
        if self.cors_origins_str == "*":
            return ["*"]
        return [origin.strip() for origin in self.cors_origins_str.split(",")]
    
    model_config = SettingsConfigDict(
        env_file=".env",
        case_sensitive=False,
        extra="ignore"
    )
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Use mongodb_uri if mongodb_url is default
        if self.mongodb_uri and self.mongodb_url == "mongodb://localhost:27017":
            self.mongodb_url = self.mongodb_uri


settings = Settings()

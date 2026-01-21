import certifi
from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from typing import Optional
import logging

from .config import settings

logger = logging.getLogger(__name__)


class Database:
    """MongoDB Atlas database connection manager"""
    
    client: Optional[AsyncIOMotorClient] = None
    db: Optional[AsyncIOMotorDatabase] = None
    
    @classmethod
    async def connect_db(cls):
        """Connect to MongoDB Atlas"""
        try:
            logger.info("Connecting to MongoDB Atlas...")
            cls.client = AsyncIOMotorClient(
                settings.mongodb_url,
                tlsCAFile=certifi.where(),
                serverSelectionTimeoutMS=5000,
                connectTimeoutMS=10000,
                socketTimeoutMS=10000,
            )
            
            # Verify connection
            await cls.client.admin.command('ping')
            
            cls.db = cls.client[settings.database_name]
            logger.info(f"Connected to MongoDB Atlas database: {settings.database_name}")
            
            # Create indexes
            await cls.create_indexes()
            
        except Exception as e:
            logger.error(f"Failed to connect to MongoDB Atlas: {e}")
            raise
    
    @classmethod
    async def close_db(cls):
        """Close MongoDB connection"""
        if cls.client:
            cls.client.close()
            logger.info("MongoDB connection closed")
    
    @classmethod
    def get_database(cls) -> AsyncIOMotorDatabase:
        """Get database instance"""
        if cls.db is None:
            raise RuntimeError("Database not connected. Call connect_db() first.")
        return cls.db
    
    @classmethod
    async def create_indexes(cls):
        """Create database indexes for better performance"""
        if cls.db is None:
            return
            
        try:
            # Users collection indexes
            await cls.db.users.create_index("email", unique=True)
            await cls.db.users.create_index("username", unique=True)
            
            # Passwords collection indexes
            await cls.db.passwords.create_index("user_id")
            await cls.db.passwords.create_index("shared_vault_id")
            await cls.db.passwords.create_index([("user_id", 1), ("category", 1)])
            await cls.db.passwords.create_index([("user_id", 1), ("created_at", -1)])
            await cls.db.passwords.create_index([
                ("user_id", 1),
                ("title", "text"),
                ("username", "text")
            ])
            
            # Teams collection indexes
            await cls.db.teams.create_index("code", unique=True)
            await cls.db.teams.create_index("members.user_id")
            
            # Shared Vaults collection indexes
            await cls.db.shared_vaults.create_index("team_id")

            
            logger.info("Database indexes created successfully")
            
        except Exception as e:
            logger.warning(f"Index creation warning (may already exist): {e}")


async def get_database() -> AsyncIOMotorDatabase:
    """Dependency for getting database instance"""
    return Database.get_database()

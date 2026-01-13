from typing import Dict, List, Optional
from datetime import datetime
from bson import ObjectId
import logging
import json
import os

logger = logging.getLogger(__name__)

DB_FILE = "data.json"

class InMemoryDatabase:
    """In-memory database with JSON persistence for development"""
    
    users: Dict[str, dict] = {}
    passwords: Dict[str, dict] = {}
    
    @classmethod
    def _save_data(cls):
        """Save data to JSON file"""
        try:
            with open(DB_FILE, 'w') as f:
                json.dump({
                    "users": cls.users,
                    "passwords": cls.passwords
                }, f, default=str)
        except Exception as e:
            logger.error(f"Failed to save database: {e}")

    @classmethod
    def _load_data(cls):
        """Load data from JSON file"""
        if os.path.exists(DB_FILE):
            try:
                with open(DB_FILE, 'r') as f:
                    data = json.load(f)
                    cls.users = data.get("users", {})
                    cls.passwords = data.get("passwords", {})
            except Exception as e:
                logger.error(f"Failed to load database: {e}")
                cls.users = {}
                cls.passwords = {}
        else:
            cls.users = {}
            cls.passwords = {}

    @classmethod
    async def connect_db(cls):
        """Initialize in-memory database and load data"""
        logger.info("Using JSON-backed database (no MongoDB required)")
        cls._load_data()
    
    @classmethod
    async def close_db(cls):
        """Save and close database"""
        cls._save_data()
        logger.info("Database saved and closed")
    
    @classmethod
    def get_database(cls):
        """Get database instance"""
        return cls
    
    @classmethod
    async def create_indexes(cls):
        """No-op for in-memory database"""
        logger.info("Database initialized")


class InMemoryCollection:
    """In-memory collection that mimics MongoDB collection"""
    
    def __init__(self, data: Dict[str, dict], db_class):
        self.data = data
        self.db_class = db_class
    
    async def insert_one(self, document: dict):
        """Insert a document"""
        if '_id' not in document or document['_id'] is None:
            doc_id = str(ObjectId())
            document['_id'] = doc_id
        else:
            doc_id = str(document['_id'])
            
        self.data[doc_id] = document
        self.db_class._save_data()
        
        class InsertResult:
            def __init__(self, inserted_id):
                self.inserted_id = inserted_id
        
        return InsertResult(doc_id)
    
    async def find_one(self, query: dict):
        """Find one document"""
        # Handle _id query
        if '_id' in query and isinstance(query['_id'], (str, ObjectId)):
            doc = self.data.get(str(query['_id']))
            if doc:
                match = True
                for key, value in query.items():
                    if key != '_id' and doc.get(key) != value:
                        match = False
                        break
                if match:
                    return doc
            return None

        # Handle $or query
        if '$or' in query:
            or_clauses = query['$or']
            for doc in self.data.values():
                for clause in or_clauses:
                    clause_match = True
                    for k, v in clause.items():
                        if doc.get(k) != v:
                            clause_match = False
                            break
                    if clause_match:
                        return doc
            return None

        for doc in self.data.values():
            match = True
            for key, value in query.items():
                if doc.get(key) != value:
                    match = False
                    break
            if match:
                return doc
        return None
    
    async def find(self, query: dict = None):
        """Find documents"""
        if query is None:
            query = {}
        
        results = []
        for doc in self.data.values():
            match = True
            
            # Handle top-level keys
            for key, value in query.items():
                if key == '$or':
                    or_match = False
                    for clause in value:
                        clause_match = True
                        for k, v in clause.items():
                            if isinstance(v, dict) and '$regex' in v:
                                pattern = v['$regex']
                                if pattern.lower() not in str(doc.get(k, "")).lower():
                                    clause_match = False
                                    break
                            elif doc.get(k) != v:
                                clause_match = False
                                break
                        if clause_match:
                            or_match = True
                            break
                    if not or_match:
                        match = False
                        break
                elif key == '_id':
                    if str(doc.get('_id')) != str(value):
                        match = False
                        break
                elif isinstance(value, dict) and '$regex' in value:
                    pattern = value['$regex']
                    if pattern.lower() not in str(doc.get(key, "")).lower():
                        match = False
                        break
                elif doc.get(key) != value:
                    match = False
                    break
            
            if match:
                results.append(doc)
        
        class Cursor:
            def __init__(self, results):
                self.results = results
            
            def sort(self, key, direction=1):
                """Simple sort support"""
                self.results.sort(key=lambda x: x.get(key), reverse=(direction == -1))
                return self
            
            async def to_list(self, length=None):
                return self.results if length is None else self.results[:length]
        
        return Cursor(results)
    
    async def update_one(self, query: dict, update: dict):
        """Update one document"""
        found_doc = None
        # Try ID lookup first
        if '_id' in query:
            found_doc = self.data.get(str(query['_id']))
        else:
            for doc in self.data.values():
                match = True
                for key, value in query.items():
                    if doc.get(key) != value:
                        match = False
                        break
                if match:
                    found_doc = doc
                    break
        
        if found_doc:
            if '$set' in update:
                found_doc.update(update['$set'])
            self.db_class._save_data()
            
            class UpdateResult:
                def __init__(self):
                    self.modified_count = 1
            
            return UpdateResult()
        
        class UpdateResult:
            def __init__(self):
                self.modified_count = 0
        
        return UpdateResult()
    
    async def delete_one(self, query: dict):
        """Delete one document"""
        doc_to_delete = None
        if '_id' in query:
            doc_id = str(query['_id'])
            if doc_id in self.data:
                doc_to_delete = doc_id
        else:
            for doc_id, doc in self.data.items():
                match = True
                for key, value in query.items():
                    if doc.get(key) != value:
                        match = False
                        break
                if match:
                    doc_to_delete = doc_id
                    break
        
        if doc_to_delete:
            del self.data[doc_to_delete]
            self.db_class._save_data()
            
            class DeleteResult:
                def __init__(self):
                    self.deleted_count = 1
            
            return DeleteResult()
        
        class DeleteResult:
            def __init__(self):
                self.deleted_count = 0
        
        return DeleteResult()
    
    async def create_index(self, *args, **kwargs):
        """No-op for in-memory database"""
        pass


class InMemoryDB:
    """In-memory database that mimics MongoDB database"""
    
    def __init__(self):
        self.users_data = InMemoryDatabase.users
        self.passwords_data = InMemoryDatabase.passwords
    
    @property
    def users(self):
        return InMemoryCollection(self.users_data, InMemoryDatabase)
    
    @property
    def passwords(self):
        return InMemoryCollection(self.passwords_data, InMemoryDatabase)


# Replace Database class
Database = InMemoryDatabase


# Dependency to get database
async def get_database():
    """Dependency for getting database instance"""
    return InMemoryDB()

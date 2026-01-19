
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
import os
from dotenv import load_dotenv
import certifi

async def test_connection():
    load_dotenv()
    uri = os.getenv("MONGODB_URL")
    print(f"Testing connection to: {uri.split('@')[-1]}")
    
    # Mode 1: Standard with certifi
    print("\n--- Try 1: Standard with certifi ---")
    try:
        client = AsyncIOMotorClient(uri, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)
        await client.admin.command('ping')
        print("PASS: Success with Try 1!")
        return
    except Exception as e:
        print(f"FAIL: Try 1 failed: {e}")

    # Mode 2: Allow invalid certificates (Debugging only)
    print("\n--- Try 2: Allow invalid certificates ---")
    try:
        client = AsyncIOMotorClient(uri, tlsAllowInvalidCertificates=True, serverSelectionTimeoutMS=5000)
        await client.admin.command('ping')
        print("PASS: Success with Try 2! (Certificate validation is the issue)")
        return
    except Exception as e:
        print(f"FAIL: Try 2 failed: {e}")

    # Mode 3: Long URI strategy
    print("\n--- Try 3: Shard-direct connection ---")
    try:
        # Construct long URI - updating to the user's secret keys if possible
        # credentials taken from .env shown earlier: Vishwam:vqdv0coQwtaLivLX
        long_uri = "mongodb://Vishwam:vqdv0coQwtaLivLX@ac-iqzrcx1-shard-00-00.tevhrmw.mongodb.net:27017,ac-iqzrcx1-shard-00-01.tevhrmw.mongodb.net:27017,ac-iqzrcx1-shard-00-02.tevhrmw.mongodb.net:27017/password_manager?ssl=true&replicaSet=atlas-iqzrcx-shard-0&authSource=admin"
        client = AsyncIOMotorClient(long_uri, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)
        await client.admin.command('ping')
        print("PASS: Success with Try 3!")
        return
    except Exception as e:
        print(f"FAIL: Try 3 failed: {e}")

    print("\nCRITICAL: All connection methods failed with SSL Handshake issues.")
    print("This almost always means:")
    print("1. Your IP address is NOT whitelisted in Atlas.")
    print("2. You are using a VPN or local Firewall that intercepts SSL.")

if __name__ == "__main__":
    asyncio.run(test_connection())

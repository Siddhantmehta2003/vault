
import requests
import json
from typing import Optional

BASE_URL = "http://localhost:8000"


class PasswordManagerTester:
    def __init__(self):
        self.token: Optional[str] = None
        self.master_password = "TestMaster123!"
        self.test_user = {
            "email": "test@example.com",
            "username": "testuser",
            "password": "TestPassword123!",
            "master_password": self.master_password
        }
        self.password_id: Optional[str] = None
    
    def print_response(self, title: str, response: requests.Response):
        """Print formatted response"""
        print(f"\n{'='*60}")
        print(f"TEST: {title}")
        print(f"{'='*60}")
        print(f"Status Code: {response.status_code}")
        try:
            print(f"Response: {json.dumps(response.json(), indent=2)}")
        except:
            print(f"Response: {response.text}")
        print(f"{'='*60}\n")
    
    def test_health(self):
        """Test health endpoint"""
        response = requests.get(f"{BASE_URL}/health")
        self.print_response("Health Check", response)
        return response.status_code == 200
    
    def test_register(self):
        """Test user registration"""
        response = requests.post(
            f"{BASE_URL}/api/auth/register",
            json=self.test_user
        )
        self.print_response("User Registration", response)
        return response.status_code == 201
    
    def test_login(self):
        """Test user login"""
        response = requests.post(
            f"{BASE_URL}/api/auth/login",
            data={
                "username": self.test_user["username"],
                "password": self.test_user["password"]
            }
        )
        self.print_response("User Login", response)
        
        if response.status_code == 200:
            self.token = response.json()["access_token"]
            print(f"✅ Token saved: {self.token[:50]}...")
            return True
        return False
    
    def get_headers(self, include_master_password=True):
        """Get request headers"""
        headers = {
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json"
        }
        if include_master_password:
            headers["X-Master-Password"] = self.master_password
        return headers
    
    def test_create_password(self):
        """Test creating a password entry"""
        password_data = {
            "title": "Gmail Account",
            "username": "admin@trimesha.com",
            "password": "Chalsekadach@007",
            "url": "https://gmail.com",
            "notes": "Company email account",
            "category": "Email"
        }
        
        response = requests.post(
            f"{BASE_URL}/api/passwords/",
            headers=self.get_headers(),
            json=password_data
        )
        self.print_response("Create Password", response)
        
        if response.status_code == 201:
            self.password_id = response.json()["id"]
            print(f"✅ Password ID saved: {self.password_id}")
            return True
        return False
    
    def test_get_passwords(self):
        """Test getting all passwords"""
        response = requests.get(
            f"{BASE_URL}/api/passwords/",
            headers=self.get_headers()
        )
        self.print_response("Get All Passwords", response)
        return response.status_code == 200
    
    def test_get_single_password(self):
        """Test getting a single password"""
        if not self.password_id:
            print("⚠️  No password ID available, skipping test")
            return False
        
        response = requests.get(
            f"{BASE_URL}/api/passwords/{self.password_id}",
            headers=self.get_headers()
        )
        self.print_response("Get Single Password", response)
        return response.status_code == 200
    
    def test_update_password(self):
        """Test updating a password"""
        if not self.password_id:
            print("⚠️  No password ID available, skipping test")
            return False
        
        update_data = {
            "title": "Gmail Account (Updated)",
            "password": "NewSecurePassword456!"
        }
        
        response = requests.put(
            f"{BASE_URL}/api/passwords/{self.password_id}",
            headers=self.get_headers(),
            json=update_data
        )
        self.print_response("Update Password", response)
        return response.status_code == 200
    
    def test_search_passwords(self):
        """Test searching passwords"""
        response = requests.get(
            f"{BASE_URL}/api/passwords/?search=gmail",
            headers=self.get_headers()
        )
        self.print_response("Search Passwords", response)
        return response.status_code == 200
    
    def test_filter_by_category(self):
        """Test filtering by category"""
        response = requests.get(
            f"{BASE_URL}/api/passwords/?category=Email",
            headers=self.get_headers()
        )
        self.print_response("Filter by Category", response)
        return response.status_code == 200
    
    def test_get_categories(self):
        """Test getting categories"""
        response = requests.get(
            f"{BASE_URL}/api/passwords/categories/list",
            headers=self.get_headers(include_master_password=False)
        )
        self.print_response("Get Categories", response)
        return response.status_code == 200
    
    def test_delete_password(self):
        """Test deleting a password"""
        if not self.password_id:
            print("⚠️  No password ID available, skipping test")
            return False
        
        response = requests.delete(
            f"{BASE_URL}/api/passwords/{self.password_id}",
            headers=self.get_headers(include_master_password=False)
        )
        self.print_response("Delete Password", response)
        return response.status_code == 200
    
    def run_all_tests(self):
        """Run all tests in sequence"""
        print("\n" + "="*60)
        print("PASSWORD MANAGER API TEST SUITE")
        print("="*60)
        
        tests = [
            ("Health Check", self.test_health),
            ("User Registration", self.test_register),
            ("User Login", self.test_login),
            ("Create Password", self.test_create_password),
            ("Get All Passwords", self.test_get_passwords),
            ("Get Single Password", self.test_get_single_password),
            ("Update Password", self.test_update_password),
            ("Search Passwords", self.test_search_passwords),
            ("Filter by Category", self.test_filter_by_category),
            ("Get Categories", self.test_get_categories),
            ("Delete Password", self.test_delete_password),
        ]
        
        results = []
        for name, test_func in tests:
            try:
                result = test_func()
                results.append((name, result))
            except Exception as e:
                print(f"\n❌ Error in {name}: {str(e)}\n")
                results.append((name, False))
        
        # Print summary
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        
        passed = sum(1 for _, result in results if result)
        total = len(results)
        
        for name, result in results:
            status = "✅ PASSED" if result else "❌ FAILED"
            print(f"{status}: {name}")
        
        print(f"\nTotal: {passed}/{total} tests passed")
        print("="*60 + "\n")
        
        return passed == total


def main():
    """Main test runner"""
    print("Starting Password Manager API Tests...")
    print(f"Base URL: {BASE_URL}")
    print("\nMake sure the server is running at {BASE_URL}")
    print("Start server with: uvicorn app.main:app --reload\n")
    
    # input("Press Enter to continue...")
    
    tester = PasswordManagerTester()
    success = tester.run_all_tests()
    
    if success:
        print("🎉 All tests passed!")
        return 0
    else:
        print("⚠️  Some tests failed. Check the output above.")
        return 1


if __name__ == "__main__":
    exit(main())

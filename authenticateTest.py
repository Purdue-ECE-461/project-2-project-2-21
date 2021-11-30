"""Tests Authenticate.py"""

import unittest
import authenticate

class Authenticate_Tests(unittest.TestCase):
    """A series of authentication tests to register and delete users."""

    def test_register_admin(self):
        """Test successful admin registration."""
        auth = authenticate.Authenticator()
        auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        self.assertNotEqual(len(auth.database), 0, "No users have been registered!")
        self.assertNotEqual(len(auth.admin_tokens), 0, "No admins have been registered!")
        #print("Admin registered")
        #print("Admins:", auth.admin_tokens)

    def test_register_user(self):
        """Test successful user registration."""
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "fake user".encode('utf-8'),
                               "breakable password".encode('utf-8'))
        self.assertNotEqual(auth.database["fake user".encode('utf-8')], None)
        #print("User registered")
        #print("Users:", auth.database)

    def test_delete_user(self):
        """Test successful user deletion"""
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "asbf".encode('utf-8'),
                                "breakable password".encode('utf-8'))
        #print("User registered")
        #print("Users:", auth.database)
        auth.delete_user("asbf".encode('utf-8'))
        #print("User deleted")
        #print("Users:", auth.database)
        self.assertIsNone(auth.database["asbf".encode('utf-8')], "User failed to delete")

if __name__ == "__main__":
    unittest.main()

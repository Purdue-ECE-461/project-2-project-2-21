"""Tests the overall functionality of the authentication functions."""
import unittest
import authenticate


class Tester(unittest.TestCase):
    """Tests authentication functionality in authenticate.py"""
    def test_register_admin(self):
        """
        Tests registration of admin in authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        self.assertNotEqual(len(auth.database), 0, "No users have been registered!")
        self.assertNotEqual(len(auth.admin_tokens), 0, "No admins have been registered!")
        self.assertIsNotNone(tok)

    def test_register_user(self):
        """
        Tests registration of user in authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "fake user".encode('utf-8'),
                               "breakable password".encode('utf-8'))
        self.assertNotEqual(auth.database["fake user".encode('utf-8')], None)

    def test_delete_user(self):
        """
        Tests deletion of user from authentication db
        """
        auth = authenticate.Authenticator()
        tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
        auth.register_user("leij".encode('utf-8'), tok, "asbf".encode('utf-8'),
                                "breakable password".encode('utf-8'))
        auth.delete_user("asbf".encode('utf-8'))
        try:
            auth.database["asbf".encode('utf-8')]
        except KeyError as exception:
            self.assertNotEqual(exception, None, "User failed to delete")


if __name__ == "__main__":
    unittest.main()

"""Authenticates a user for database access."""

import bcrypt

class Authenticator:
    """
    Authentication class that manages adding, removing,
    and authenticating users based on credentials such as
    username and password. The passwords are hashed and salted.
    """
    def __init__(self):
        # Database dictionary from username to password hash
        self.database = {}
        # Dictionary admin usernames to hashed admin tokens that have been distributed
        self.admin_tokens = {}

    def register_user(self, admin_username, admin_token, username, password):
        """
        Registers new username and password using given admin token.
        This means only admins will be able to register users.
        Returns True if new user is registered, and False otherwise.
        """
        # Check that the admin_token is valid for admin_username.
        admin_hash = self.admin_tokens[admin_username].encode('utf-8')

        # admin_token passes, register the new user. If user already exists, overwrite password
        if self.check_hash(admin_token, admin_hash):
            user_hash = self.get_hash(password)
            self.database[username] = user_hash
            return True

        # admin token failed, print error and do not register user
        print("Admin username or token is incorrect.")
        return False

    def register_admin(self, admin_username, admin_password):
        """
        Registers new admin. USE WITH CAUTION. WILL LIKELY REQUIRE FUTURE CHANGES FOR SECURITY.
        """
        admin_hash = self.get_hash(admin_password)
        self.database[admin_username] = admin_hash
        token = "THIS IS A TEMP TOKEN, FIX THIS LATER".encode('utf-8')
        token_hash = self.get_hash(token)
        self.admin_tokens[admin_username] = token_hash
        return token

    def delete_user(self, username):
        """
        Deletes user given their username
        """
        if username in self.admin_tokens:
            del self.admin_tokens[username]
        if username in self.database:
            del self.database[username]

    def get_hash(self, password):
        """
        Hash a password or token for the first time using bcrypt.
        """
        pwhash = bcrypt.hashpw(password, bcrypt.gensalt(12))
        decoded = pwhash.decode('utf8')
        return decoded

    def check_hash(self, plaintext, hash_value):
        """
        Checks hashed password or token.
        """
        checked_password = bcrypt.checkpw(plaintext, hash_value)
        return checked_password

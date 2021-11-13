import authenticate


auth = authenticate.Authenticator()

tok = auth.register_admin("leij".encode('utf-8'), "unbreakable password".encode('utf-8'))
print("admin has been created")
print(auth.database)
print(auth.admin_tokens)
auth.register_user("leij".encode('utf-8'), tok, "fake user".encode('utf-8'), "breakable password".encode('utf-8'))
print("user has been registered")
print(auth.database)
print(auth.admin_tokens)
auth.delete_user("fake user".encode('utf-8'))
print("user has been deleted")
print(auth.database)
print(auth.admin_tokens)
auth.delete_user("leij".encode('utf-8'))
print("admin has been created")
print(auth.database)
print(auth.admin_tokens)

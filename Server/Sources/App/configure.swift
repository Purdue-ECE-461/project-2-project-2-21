import Vapor
import VaporFirestore

// configures your application
public func configure(_ app: Application) throws {
        
    app.storage[FirestoreConfig.FirestoreConfigKey.self] = FirestoreConfig(
        projectId: Environment.get("FS_PRJ_KEY")!,
        email: Environment.get("FS_EMAIL_KEY")!,
        privateKey: Environment.get("FS_PRIVKEY_KEY")!
    )
    
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(UserAuthenticator())
    
    // register routes
    try routes(app)
}

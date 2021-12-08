import Vapor
import VaporFirestore
import JWT

// configures your application
public func configure(_ app: Application) throws {
        
    app.storage[FirestoreConfig.FirestoreConfigKey.self] = FirestoreConfig(
        projectId: Environment.get("FS_PRJ_KEY")!,
        email: Environment.get("FS_EMAIL_KEY")!,
        privateKey: Environment.get("FS_PRIVKEY_KEY")!
    )
    
    // Add HMAC with SHA-256 signer.
    app.jwt.signers.use(.hs256(key: "ece-461-project-2-secret-key"))
    
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.middleware.use(UserAuthenticator(app: app), at: .beginning)
    
    // register routes
    try routes(app)
}

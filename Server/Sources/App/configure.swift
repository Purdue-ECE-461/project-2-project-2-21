import JWT
import Vapor
import VaporFirestore

// configures your application
public func configure(_ app: Application) throws {

    app.storage[FirestoreConfig.FirestoreConfigKey.self] = FirestoreConfig(
        projectId: Environment.get("FS_PRJ_KEY")!,
        email: Environment.get("FS_EMAIL_KEY")!,
        privateKey: Environment.get("FS_PRIVKEY_KEY")!
    )

    // Add HMAC with SHA-256 signer.
    app.jwt.signers.use(.hs256(key: "ece-461-project-2-secret-key"))

    app.middleware.use(UserAuthenticator(app: app), at: .beginning)
    app.middleware.use(LoggingMiddleware(app: app))

    // register routes
    try routes(app)
}

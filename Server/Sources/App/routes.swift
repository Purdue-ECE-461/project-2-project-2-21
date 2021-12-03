import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PackageController())
    try app.register(collection: AuthController())
    try app.register(collection: ResetController())
}

import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PackageController(app: app))
    try app.register(collection: AuthController())
    try app.register(collection: ResetController())
}

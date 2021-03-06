import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: PackageController(app: app))
    try app.register(collection: PackagesController(app: app))
    try app.register(collection: AuthController(app: app))
    try app.register(collection: ResetController(app: app))
}

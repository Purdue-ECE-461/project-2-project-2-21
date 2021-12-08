@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    
    private var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    // TODO: Add create package
    func testCreatePackage() throws {
        guard let fileURL = Bundle.module.url(forResource: "temporary", withExtension: "json", subdirectory: "MockData/Packages") else {
            XCTFail("File not found.")
            return
        }

        let jsonData = try Data(contentsOf: fileURL)
        let package = try JSONDecoder().decode(ProjectPackage.self, from: jsonData)

        try app.test(.POST, "package", beforeRequest: { req in
            try req.content.encode(package)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .created)
            XCTAssertEqual(res.headers.contentType, .json)

            let metadata = try res.content.decode(ProjectPackage.Metadata.self)
            XCTAssertEqual(package.metadata.id, metadata.id)
            XCTAssertEqual(package.metadata.version, metadata.version)
            XCTAssertEqual(package.metadata.name, metadata.name)
            
            try app.test(.DELETE, "temporary", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
            })
        })
    }
    
    func testGETExistentPackagePackageResponseByID() throws {
        try app.test(.GET, "package/underscore", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
        })
    }
    
    func testGETNonExistentPackagePackageResponseByID() throws {
        try app.test(.GET, "package/does_not_exist", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .internalServerError)
            XCTAssertEqual(res.headers.contentType, .json)
            let errorResponse = try res.content.decode(InternalError.self)
            XCTAssertEqual(errorResponse.code, -1)
            XCTAssertEqual(errorResponse.message, "An error occurred while retrieving package")
        })
    }
    
    func testPUTUnderscorePackageResponseByID() throws {
        try app.test(.PUT, "package/underscore", beforeRequest: { req in
            let package = ProjectPackage.mock
            try req.content.encode(package)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .plainText)
        })
    }
    
//    func testPUTPackageResponseByIDError() throws {
//        try app.test(.PUT, "package/does_not_exist", beforeRequest: { req in
//            let package = ProjectPackage.doesNotExist
//            try req.content.encode(package)
//        }, afterResponse: { res in
//            XCTAssertEqual(res.status, .internalServerError)
//            XCTAssertEqual(res.headers.contentType, .plainText)
//        })
//    }
    
    func testDELETETemporaryPackageResponseByID() throws {
        // TODO: Create a deletable object
        
        try app.test(.POST, "package", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
            try req.content.encode(ProjectPackage.temporary)
        })

        try app.test(.DELETE, "package/temporary", beforeRequest: { req in
            let package = ProjectPackage.mock
            try req.content.encode(package)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .plainText)
        })
    }
    
    func testAttemptDELETENonExistentPackageResponseByID() throws {
        try app.test(.DELETE, "package/does_not_exist", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.headers.contentType, .plainText)
        })
    }
    
    func testGETRate() throws {
        try app.test(.GET, "package/underscore/rate", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let score = try res.content.decode(PackageScore.self)
            
            XCTAssertGreaterThanOrEqual(score.rampUp, 0)
            XCTAssertLessThanOrEqual(score.rampUp, 1)
            
            XCTAssertGreaterThanOrEqual(score.correctness, 0)
            XCTAssertLessThanOrEqual(score.correctness, 1)
            
            XCTAssertGreaterThanOrEqual(score.busFactor, 0)
            XCTAssertLessThanOrEqual(score.busFactor, 1)
            
            XCTAssertGreaterThanOrEqual(score.responsiveMaintainer, 0)
            XCTAssertLessThanOrEqual(score.responsiveMaintainer, 1)
            
            XCTAssertGreaterThanOrEqual(score.licenseScore, 0)
            XCTAssertLessThanOrEqual(score.licenseScore, 1)
            
            XCTAssertGreaterThanOrEqual(score.goodPinningPractice, 0)
            XCTAssertLessThanOrEqual(score.goodPinningPractice, 1)
        })
    }
    
    // TODO: This will remove all packages
//    func testAuthenticatedReset() throws {
//        try app.test(.DELETE, "reset", afterResponse: { res in
//            XCTAssertEqual(res.status, .ok)
//            XCTAssertEqual(res.headers.contentType, .plainText)
//        })
//    }
    
    func testCreateAuthToken() throws {
        try app.test(.PUT, "authenticate", beforeRequest: { req in
            let authRequest = AuthenticationRequest.mock
            try req.content.encode(authRequest)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
            XCTAssertFalse(res.body.string.isEmpty)
        })
    }
    
    func testGETPackageHistoryByName() throws {
        try app.test(.GET, "package/byName/Underscore", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
            _ = try res.content.decode([PackageHistoryItem].self)
        })
    }
    
    func testDELETEPackageVersionsByName() throws {
        try app.test(.DELETE, "package/byName/express", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .plainText)
            XCTAssertEqual(res.body.string, "") // Ensure empty response
        })
    }
    
    func testPOSTGetPackages() throws {
        try app.test(.POST, "packages", beforeRequest: { req in
            let packagesRequest = ProjectPackageRequest.mockList
            try req.content.encode(packagesRequest)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
    
    func testUnauthorizedAccess() throws {
        try app.test(.GET, "")
    }
    
    func testGETExpressPackage() throws {
        try app.test(.GET, "package/express", beforeRequest: { req in
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)
            let payload = try res.content.decode(ProjectPackage.self)
            print(payload.data.content.count)
        })
    }
}

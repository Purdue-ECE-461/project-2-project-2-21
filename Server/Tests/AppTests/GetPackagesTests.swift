@testable import App
import XCTVapor

final class GetPackagesTests: XCTestCase {
    
    private var app: Application!
    
    override func setUpWithError() throws {
        app = Application(.testing)
        try configure(app)
    }
    
    override func tearDownWithError() throws {
        app.shutdown()
    }
    
    func testPOSTGetPackagesNoOffset() throws {
        try app.test(.POST, "packages", beforeRequest: { req in
            let packagesRequest = ProjectPackageRequest.mockList
            try req.content.encode(packagesRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
//            let packages = try res.content.decode([ProjectPackage].self)
//            print(packages)
        })
    }
    
    func testPOSTGetPackagesOffset1() throws {
        try app.test(.POST, "packages?offset=1", beforeRequest: { req in
            let packagesRequest = ProjectPackageRequest.mockList
            try req.content.encode(packagesRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
    
    func testPOSTGetPackagesOffset2() throws {
        try app.test(.POST, "packages?offset=2", beforeRequest: { req in
            let packagesRequest = ProjectPackageRequest.mockList
            try req.content.encode(packagesRequest)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}

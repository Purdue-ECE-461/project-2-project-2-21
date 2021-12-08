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
    
    //    func testPOSTGetPackagesNoOffset() throws {
    //        try app.test(.POST, "packages", beforeRequest: { req in
    //            let packagesRequest = ProjectPackageRequest.mockList
    //            try req.content.encode(packagesRequest)
    //        }, afterResponse: { res in
    //            XCTAssertEqual(res.status, .ok)
    //            let packages = try res.content.decode([ProjectPackage].self)
    //            print(packages)
    //        })
    //    }
    
    //    func testPOSTGetPackagesOffset1() throws {
    //        try app.test(.POST, "packages?offset=1", beforeRequest: { req in
    //            let packagesRequest = ProjectPackageRequest.mockList
    //            try req.content.encode(packagesRequest)
    //        }, afterResponse: { res in
    //            XCTAssertEqual(res.status, .ok)
    //        })
    //    }
    
    //    func testPOSTGetPackagesOffset2() throws {
    //        try app.test(.POST, "packages?offset=2", beforeRequest: { req in
    //            let packagesRequest = ProjectPackageRequest.mockList
    //            try req.content.encode(packagesRequest)
    //        }, afterResponse: { res in
    //            XCTAssertEqual(res.status, .ok)
    //        })
    //    }
    
    func testPOSTGetPackages() throws {
        let packagesToCreate = Self.mockPacakgesForRequest
        let packagesRequest = Self.mockRequest
        
        // Create the packages
        for package in packagesToCreate {
            try app.test(.POST, "package", beforeRequest: { req in
                try req.content.encode(package)
                req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
            })
        }

        // Get the packages
        try app.test(.POST, "packages?offset=1", beforeRequest: { req in
            try req.content.encode(packagesRequest)
            req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.headers.contentType, .json)

            let matchingPackages = try res.content.decode([ProjectPackage.Metadata].self)
            XCTAssertEqual(matchingPackages.count, Self.matchingPacakgesForRequest.count)

            for expectedPackage in Self.matchingPacakgesForRequest {
                let doesContain = matchingPackages.contains { $0.version == expectedPackage.metadata.version && $0.id == expectedPackage.metadata.id }
                XCTAssertTrue(doesContain)
            }
        })
        
        // Delete the packages
        for package in packagesToCreate {
            try app.test(.DELETE, "package/\(package.metadata.id)", beforeRequest: { req in
                req.headers.bearerAuthorization = BearerAuthorization(token: Environment.get("BEARER_TOKEN")!)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        }
    }
}

private extension GetPackagesTests {
    static let mockPacakgesForRequest = [
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "1.2.3",
                id: "mock1123"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "1.2.10",
                id: "mock11210"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "1.3.0",
                id: "mock1130"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "2.0.0",
                id: "mock1200"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock2",
                version: "1.2.3",
                id: "mock2123"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock2",
                version: "1.5.7",
                id: "mock2157"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock2",
                version: "2.0.0",
                id: "mock2200"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "1.2.2",
                id: "mock3123"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "2.0.0",
                id: "mock3200"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "2.3.4",
                id: "mock3234"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "2.3.5",
                id: "mock3235"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock4",
                version: "4.6.8",
                id: "mock4468"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock4",
                version: "5.7.9",
                id: "mock4579"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock5",
                version: "0.2.10",
                id: "mock50210"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock5",
                version: "0.3.0",
                id: "mock5030"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock6",
                version: "0.0.1",
                id: "mock6001"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock6",
                version: "0.0.2",
                id: "mock6002"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock7",
                version: "10.100.1000",
                id: "mock7101001000"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        )
    ]
    
    static let matchingPacakgesForRequest = [
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "1.2.3",
                id: "mock1123"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock1",
                version: "1.2.10",
                id: "mock11210"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock2",
                version: "1.2.3",
                id: "mock2123"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock2",
                version: "1.5.7",
                id: "mock2157"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "2.0.0",
                id: "mock3200"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock3",
                version: "2.3.4",
                id: "mock3234"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock4",
                version: "4.6.8",
                id: "mock4468"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock5",
                version: "0.2.10",
                id: "mock50210"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock6",
                version: "0.0.1",
                id: "mock6001"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        ),
        ProjectPackage(
            metadata: ProjectPackage.Metadata(
                name: "mock7",
                version: "10.100.1000",
                id: "mock7101001000"
            ),
            data: ProjectPackage.PackageData(
                content: "ABC123",
                url: "www.google.com"
            )
        )
    ]
    
    static let mockRequest = [
        ProjectPackageRequest(
            version: "~1.2.3",
            name: "mock1"
        ),
        ProjectPackageRequest(
            version: "^1.2.3",
            name: "mock2"
        ),
        ProjectPackageRequest(
            version: "1.2.3-2.3.4",
            name: "mock3"
        ),
        ProjectPackageRequest(
            version: "4.6.8",
            name: "mock4"
        ),
        ProjectPackageRequest(
            version: "^0.2.3",
            name: "mock5"
        ),
        ProjectPackageRequest(
            version: "^0.0.1",
            name: "mock6"
        ),
        ProjectPackageRequest(
            version: "0.1.2",
            name: "EXACT_PACKAGE_DOES_NOT_EXIST"
        ),
        ProjectPackageRequest(
            version: "*",
            name: ""
        ),
        ProjectPackageRequest(
            version: "*",
            name: "mock7"
        )
    ]
}

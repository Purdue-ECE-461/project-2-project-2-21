//
//  ProjectPackageTests.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

@testable import App
import Foundation
import XCTest

final class ProjectPackageTests: XCTestCase {
    func testDecodableUnderscorePackage() throws {
        guard let fileURL = Bundle.module.url(
            forResource: "underscore",
            withExtension: "json",
            subdirectory: "MockData/Packages"
        ) else {
            XCTFail("File not found")
            return
        }

        let data = try Data(contentsOf: fileURL)
        let package = try JSONDecoder().decode(ProjectPackage.self, from: data)

        XCTAssertEqual(package.data.url, "https://github.com/jashkenas/underscore")
        XCTAssertEqual(package.metadata.name, "Underscore")
        XCTAssertEqual(package.metadata.id, "underscore")
        XCTAssertEqual(package.metadata.version, "1.0.0")
    }
}

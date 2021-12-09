//
//  PackageHistoryItemTests.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

@testable import App
import Foundation
import XCTest

final class PackageHistoryItemTests: XCTestCase {
    func testDecodePackageHistoryItem() throws {
        guard let fileURL = Bundle.module.url(
            forResource: "historyItem",
            withExtension: "json",
            subdirectory: "MockData/Packages"
        ) else {
            XCTFail("File not found")
            return
        }

        let data = try Data(contentsOf: fileURL)
        let item = try JSONDecoder().decode(PackageHistoryItem.self, from: data)

        XCTAssertEqual(item.user.name, "Paschal Amusuo")
        XCTAssertTrue(item.user.isAdmin)
        XCTAssertEqual(item.date, "2021-11-21T01:11:11Z")
        XCTAssertEqual(item.packageMetadata.name, "Underscore")
        XCTAssertEqual(item.packageMetadata.version, "1.0.0")
        XCTAssertEqual(item.packageMetadata.id, "underscore")
        XCTAssertEqual(item.action, .download)

        let jsonString = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(jsonString.contains("2021-11-21T01:11:11Z"))
    }

    func testDecodePackageHistoryItems() throws {
        guard let fileURL = Bundle.module.url(
            forResource: "historyItems",
            withExtension: "json",
            subdirectory: "MockData/Packages"
        ) else {
            XCTFail("File not found")
            return
        }

        let data = try Data(contentsOf: fileURL)
        let items = try JSONDecoder().decode([PackageHistoryItem].self, from: data)
        XCTAssertEqual(items.count, 4)
    }
}

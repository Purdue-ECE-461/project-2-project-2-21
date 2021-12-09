//
//  StringVersionTests.swift
//  
//
//  Created by Charles Pisciotta on 12/8/21.
//

@testable import App
import Foundation
import XCTest

final class StringVersionTests: XCTestCase {
    func testUpToNextMinorNormal() {
        let versionRequest = "~1.2.3"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "1.2.3")
        XCTAssertEqual(versionRange.maxVer, "1.3.0")
        XCTAssertFalse(versionRange.upperIncluded)
    }

    func testUpToNextMajorNormal() {
        let versionRequest = "^1.2.3"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "1.2.3")
        XCTAssertEqual(versionRange.maxVer, "2.0.0")
        XCTAssertFalse(versionRange.upperIncluded)
    }

    func testUpToNextMinorWithMajor0() {
        let versionRequest = "^0.2.3"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "0.2.3")
        XCTAssertEqual(versionRange.maxVer, "0.3.0")
        XCTAssertFalse(versionRange.upperIncluded)
    }

    func testUpToNextMinorWithMajor0Minor0() {
        let versionRequest = "^0.0.1"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "0.0.1")
        XCTAssertEqual(versionRange.maxVer, "0.0.1")
        XCTAssertTrue(versionRange.upperIncluded)
    }

    func testAny() {
        let versionRequest = "*"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "0.0.0")
        XCTAssertNil(versionRange.maxVer)
        XCTAssertTrue(versionRange.upperIncluded)
    }

    func testRange() {
        let versionRequest = "1.2.3-4.5.6"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "1.2.3")
        XCTAssertEqual(versionRange.maxVer, "4.5.6")
        XCTAssertTrue(versionRange.upperIncluded)
    }

    func testExact() {
        let versionRequest = "1.2.3"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "1.2.3")
        XCTAssertEqual(versionRange.maxVer, "1.2.3")
        XCTAssertTrue(versionRange.upperIncluded)
    }

    func testLargeExact() {
        let versionRequest = "123.456.789"
        let versionRange = versionRequest.getMinMaxVersions()
        XCTAssertEqual(versionRange.minVer, "123.456.789")
        XCTAssertEqual(versionRange.maxVer, "123.456.789")
        XCTAssertTrue(versionRange.upperIncluded)
    }
}

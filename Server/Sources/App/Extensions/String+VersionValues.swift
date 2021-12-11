//
//  String+VersionValues.swift
//  
//
//  Created by Charles Pisciotta on 12/8/21.
//

import Foundation

struct VerRangeInfo {
    let minVer: String
    let maxVer: String?
    let upperIncluded: Bool
}

// swiftlint:disable cyclomatic_complexity
extension String {
    /// Credit: https://devhints.io/semver
    /// - Attention: Assume all versions will be MAJOR.MINOR.PATCH
    /// - Parameter version: The version request for a given package
    /// - Returns: Returns the acceptable version range object.
    func getMinMaxVersions() -> VerRangeInfo {

        // In a future update, this should handle "x" or "X".
        if self.contains("x") || self.contains("X") {
            // Assume all versions when x is seen
            assertionFailure("Did not expect \"x\" or \"X\" in version requirement string.")
            return VerRangeInfo(minVer: "0.0.0", maxVer: nil, upperIncluded: true)
        }

        if self.contains("~") {
            // Up to and excluding next minor
            //
            // Example: ~1.2.3
            // Acceptable Versions: >=1.2.3 and <1.3.0
            //
            // [NOT IMPLEMENTED] Example: ~1.2
            // Acceptable Versions: >=1.2.0 <1.3.0 (like ~1.2.0)
            //
            // [NOT IMPLEMENTED] Example: ~1
            // Acceptable Versions: 1.0.0
            let givenVer = String(self.dropFirst())

            let splitted = givenVer.split(separator: ".")

            // Error when not MAJOR.MINOR.PATCH
            guard splitted.count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH")
                // Assume specific version when error
                return VerRangeInfo(minVer: self, maxVer: self, upperIncluded: false)
            }

            let nextMajor = splitted[0]

            // Assume all versions when error
            guard let minorAsInt = Int(splitted[1]) else {
                return VerRangeInfo(minVer: givenVer, maxVer: nil, upperIncluded: true)
            }

            let nextMinor = minorAsInt + 1

            return VerRangeInfo(minVer: givenVer, maxVer: "\(nextMajor).\(nextMinor).0", upperIncluded: false)
        } else if self.contains("^") {
            // Example 1: ^1.2.3
            // Acceptable Versions: >=1.2.3 <2.0.0
            //
            // Example 2: ^0.2.3
            // Acceptable Versions: >=0.2.3 <0.3.0 (0.x.x is special)
            //
            // Example 3: ^0.0.1
            // Acceptable Versions: =0.0.1 (0.0.x is special)
            //
            // [NOT IMPLEMENTED] Example 4: ^1.2
            // Acceptable Versions: >=1.2.0 <2.0.0 (like ^1.2.0)
            //
            // [NOT IMPLEMENTED] Example 5: ^1
            // Acceptable Versions: >=1.0.0 <2.0.0
            let givenVersion = String(self.dropFirst())
            let splitted = givenVersion.split(separator: ".")

            // Error when not MAJOR.MINOR.PATCH
            guard splitted.count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH")
                // Assume specific version when error
                return VerRangeInfo(minVer: self, maxVer: self, upperIncluded: false)
            }

            let givenMajor = splitted[0]
            let givenMinor = splitted[1]

            if givenMajor == "0", givenMinor == "0" {
                // Example 3
                // Exact
                return VerRangeInfo(minVer: givenVersion, maxVer: givenVersion, upperIncluded: true)
            } else if givenMajor == "0" {
                // Example 2
                // Up to next minor
                guard let minorAsInt = Int(givenMinor) else {
                    return VerRangeInfo(minVer: givenVersion, maxVer: nil, upperIncluded: true)
                }
                let nextMinor = minorAsInt + 1
                let nextMinorVersion = "0.\(nextMinor).0"
                return VerRangeInfo(minVer: givenVersion, maxVer: nextMinorVersion, upperIncluded: false)
            } else {
                // Example 1
                // Up to next major
                guard let majorAsInt = Int(givenMajor) else {
                    return VerRangeInfo(minVer: givenVersion, maxVer: nil, upperIncluded: true)
                }
                let nextMajor = majorAsInt + 1
                let nextMajorVersion = "\(nextMajor).0.0"
                return VerRangeInfo(minVer: givenVersion, maxVer: nextMajorVersion, upperIncluded: false)
            }
        } else if self.contains("-") {
            // Example: 1.2.3 - 2.3.4
            // Acceptable Versions: >=1.2.3 <=2.3.4
            //
            // [NOT IMPLEMENTED] Example: 1.2.3 - 2.3
            // Acceptable Versions: >=1.2.3 <2.4.0
            //
            // [NOT IMPLEMENTED] Example: 1.2.3 - 2
            // Acceptable Versions: >=1.2.3 <3.0.0
            //
            // [NOT IMPLEMENTED] Example: 1.2 - 2.3.0
            // Acceptable Versions: 1.2.0 - 2.3.0
            // Range
            let splitted = self.split(separator: "-")

            guard let minVer = splitted.first, minVer.split(separator: ".").count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH-MAJOR.MINOR.PATCH. Received: \(self)")
                // Not sure what this is
                return VerRangeInfo(minVer: "0.0.0", maxVer: nil, upperIncluded: true)
            }

            guard let maxVer = splitted.last, maxVer.split(separator: ".").count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH-MAJOR.MINOR.PATCH. Received: \(self)")
                // Not sure what this is
                return VerRangeInfo(minVer: "0.0.0", maxVer: nil, upperIncluded: true)
            }

            return VerRangeInfo(minVer: String(minVer), maxVer: String(maxVer), upperIncluded: true)
        } else if self == "*" {
            // Any version
            return VerRangeInfo(minVer: "0.0.0", maxVer: nil, upperIncluded: true)
        } else {
            // Assume specific version
            // Sanity check that only 3 elements exist (major, minor, patch)
            let splitted = self.split(separator: ".")

            // Error when not MAJOR.MINOR.PATCH
            guard splitted.count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH. Received: \(self)")
                // Not sure what this is
                return VerRangeInfo(minVer: "0.0.0", maxVer: nil, upperIncluded: true)
            }

            return VerRangeInfo(minVer: self, maxVer: self, upperIncluded: true)
        }
    }
}

//
//  String+VersionValues.swift
//  
//
//  Created by Charles Pisciotta on 12/8/21.
//

import Foundation

extension String {
    /// Credit: https://devhints.io/semver
    /// - Attention: Assume all versions will be MAJOR.MINOR.PATCH
    /// - Parameter version: The version request for a given package
    /// - Returns: Returns the minimum and maximum allowed versions given the request. Also indicates if the upper bound is inclusive.
    func getMinMaxVersions() -> (minVer: String, maxVer: String?, upperIncluded: Bool) {
        
        // TODO: Handle "X"
        if self.contains("x") || self.contains("X") {
            // Assume all versions when x is seen
            return ("0.0.0", nil, true)
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
                return (self, self, false)
            }
            
            let nextMajor = splitted[0]
            
            // Assume all versions when error
            guard let minorAsInt = Int(splitted[1]) else { return (givenVer, nil, true) }
            let nextMinor = minorAsInt + 1
            
            return (givenVer, "\(nextMajor).\(nextMinor).0", false)
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
                return (self, self, false)
            }
            
            let givenMajor = splitted[0]
            let givenMinor = splitted[1]
            
            if givenMajor == "0", givenMinor == "0" {
                // Example 3
                // Exact
                return (givenVersion, givenVersion, true)
            } else if givenMajor == "0" {
                // Example 2
                // Up to next minor
                guard let minorAsInt = Int(givenMinor) else { return (givenVersion, nil, true) }
                let nextMinor = minorAsInt + 1
                let nextMinorVersion = "0.\(nextMinor).0"
                return (givenVersion, nextMinorVersion, false)
            } else {
                // Example 1
                // Up to next major
                guard let majorAsInt = Int(givenMajor) else { return (givenVersion, nil, true) }
                let nextMajor = majorAsInt + 1
                let nextMajorVersion = "\(nextMajor).0.0"
                return (givenVersion, nextMajorVersion, false)
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
                return ("0.0.0", nil, true)
            }
            
            guard let maxVer = splitted.last, maxVer.split(separator: ".").count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH-MAJOR.MINOR.PATCH. Received: \(self)")
                // Not sure what this is
                return ("0.0.0", nil, true)
            }
            
            return (String(minVer), String(maxVer), true)
        } else if self == "*" {
            // Any version
            return ("0.0.0", nil, true)
        } else {
            // Assume specific version
            // Sanity check that only 3 elements exist (major, minor, patch)
            let splitted = self.split(separator: ".")
            
            // Error when not MAJOR.MINOR.PATCH
            guard splitted.count == 3 else {
                assertionFailure("Function assumes MAJOR.MINOR.PATCH. Received: \(self)")
                // Not sure what this is
                return ("0.0.0", nil, true)
            }
            
            return (self, self, true)
        }
    }
}

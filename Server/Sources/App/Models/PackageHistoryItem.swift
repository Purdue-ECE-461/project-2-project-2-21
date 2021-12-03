//
//  PackageHistoryItem.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct PackageHistoryItem: Content, Codable {
    let user: AuthenticationRequest.User
    let date: Date
    let packageMetadata: ProjectPackage.Metadata
    let action: PackageHistoryItem.Action
    
    // TODO: Remove this init
    init(user: AuthenticationRequest.User,
         date: Date,
         packageMetadata: ProjectPackage.Metadata,
         action: String) {
        self.user = user
        self.date = date
        self.packageMetadata = packageMetadata
        self.action = Action(rawValue: action)!
    }
    
    enum CodingKeys: String, CodingKey {
        case user = "User"
        case date = "Date"
        case packageMetadata = "PackageMetadata"
        case action = "Action"
    }
        
    init(from decoder: Decoder) throws {
        let containter = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try containter.decode(AuthenticationRequest.User.self, forKey: .user)
        self.packageMetadata = try containter.decode(ProjectPackage.Metadata.self, forKey: .packageMetadata)
        self.action = try containter.decode(PackageHistoryItem.Action.self, forKey: .action)
        
        let dateString = try containter.decode(String.self, forKey: .date)
        let dateFormatter = ISO8601DateFormatter()
        
        if let date = dateFormatter.date(from: dateString) {
            self.date = date
        } else {
            assertionFailure("Date is not in ISO8601 format")
            self.date = Date()
        }
    }
}

extension PackageHistoryItem {
    enum Action: String, Codable {
        case create = "CREATE"
        case update = "UPDATE"
        case download = "DOWNLOAD"
        case rate = "RATE"
    }
}

// TODO: Remove this
extension PackageHistoryItem {
    static let item = PackageHistoryItem(
        user: AuthenticationRequest.User(
            name: "Paschal Amusuo",
            isAdmin: true
        ),
        date: Date(),
        packageMetadata: ProjectPackage.Metadata(
            name: "Underscore",
            version: "1.0.0",
            id: "underscore"
        ),
        action: "DOWNLOAD"
    )
    
    static let items: [PackageHistoryItem] = [
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-500),
            packageMetadata: ProjectPackage.Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: "DOWNLOAD"
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-1000),
            packageMetadata: ProjectPackage.Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: "UPDATE"
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-1500),
            packageMetadata: ProjectPackage.Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: "RATE"
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-2000),
            packageMetadata: ProjectPackage.Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: "CREATE"
        )
    ]
}

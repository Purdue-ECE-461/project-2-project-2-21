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
    
    #if DEBUG
    init(user: AuthenticationRequest.User,
         date: String,
         packageMetadata: ProjectPackage.Metadata,
         action: String) {
        self.user = user
        self.date = try! Date(date, strategy: .iso8601)
        self.packageMetadata = packageMetadata
        self.action = Action(rawValue: action)!
    }
    #endif
    
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

#if DEBUG
extension PackageHistoryItem {
    static let item = PackageHistoryItem(
        user: AuthenticationRequest.User(
            name: "Paschal Amusuo",
            isAdmin: true
        ),
        date: "2021-11-21T01:11:11Z",
        packageMetadata: ProjectPackage.Metadata(
            name: "Underscore",
            version: "1.0.0",
            id: "underscore"
        ),
        action: "DOWNLOAD"
    )
}
#endif

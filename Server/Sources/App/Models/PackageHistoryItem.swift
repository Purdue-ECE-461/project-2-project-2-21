//
//  PackageHistoryItem.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct FirestorePackageHistoryItem: Codable {
    @Firestore.StringValue
    var username: String

    @Firestore.BoolValue
    var isAdmin: Bool

    @Firestore.StringValue
    var date: String

    @Firestore.StringValue
    var name: String

    @Firestore.StringValue
    var id: String

    @Firestore.StringValue
    var version: String

    @Firestore.StringValue
    var action: String

    func asPackageHistoryItem() -> PackageHistoryItem {
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: username,
                isAdmin: isAdmin
            ),
            date: ISO8601DateFormatter().date(from: date) ?? Date(),
            packageMetadata: Metadata(
                name: name,
                version: version,
                id: id
            ),
            action: PackageHistoryItem.Action(rawValue: action) ?? .unknown
        )
    }
}

struct PackageHistoryItem: Content, Codable {
    let user: AuthenticationRequest.User
    let date: String
    let packageMetadata: Metadata
    let action: PackageHistoryItem.Action

    init(user: AuthenticationRequest.User,
         date: Date,
         packageMetadata: Metadata,
         action: Action) {
        self.user = user

        let dateFormatter = ISO8601DateFormatter()
        self.date = dateFormatter.string(from: date)

        self.packageMetadata = packageMetadata
        self.action = action
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
        self.packageMetadata = try containter.decode(Metadata.self, forKey: .packageMetadata)
        self.action = try containter.decode(Self.Action.self, forKey: .action)
        self.date = try containter.decode(String.self, forKey: .date)
    }

    func asFirestoreHistoryItem() -> FirestorePackageHistoryItem {
        FirestorePackageHistoryItem(
            username: user.name,
            isAdmin: user.isAdmin,
            date: date,
            name: packageMetadata.name,
            id: packageMetadata.id,
            version: packageMetadata.version,
            action: action.rawValue
        )
    }
}

extension PackageHistoryItem {
    enum Action: String, Codable {
        case create = "CREATE"
        case update = "UPDATE"
        case download = "DOWNLOAD"
        case rate = "RATE"
        case delete = "DELETE"
        /// This should never be used, but is used for nil-coalescing
        case unknown = "UNKNOWN"
    }
}

#if DEBUG
extension PackageHistoryItem {
    static let item = PackageHistoryItem(
        user: AuthenticationRequest.User(
            name: "Paschal Amusuo",
            isAdmin: true
        ),
        date: Date(),
        packageMetadata: Metadata(
            name: "Underscore",
            version: "1.0.0",
            id: "underscore"
        ),
        action: .download
    )

    static let items: [PackageHistoryItem] = [
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-500),
            packageMetadata: Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: .download
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-1_000),
            packageMetadata: Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: .update
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-1_500),
            packageMetadata: Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: .rate
        ),
        PackageHistoryItem(
            user: AuthenticationRequest.User(
                name: "Paschal Amusuo",
                isAdmin: true
            ),
            date: Date().addingTimeInterval(-2_000),
            packageMetadata: Metadata(
                name: "Underscore",
                version: "1.0.0",
                id: "underscore"
            ),
            action: .create
        )
    ]
}
#endif

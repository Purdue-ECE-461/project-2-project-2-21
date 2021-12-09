//
//  ProjectPackage.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor
import VaporFirestore

struct ProjectPackageRequest: Content, Codable {
    let version: String
    let name: String

    let minimumVersion: String
    let maximumVersion: String?
    let includesUpperBound: Bool

    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case name = "Name"
    }

    init(version: String, name: String) {
        self.version = version
        self.name = name

        let versions = version.getMinMaxVersions()
        self.minimumVersion = versions.minVer
        self.maximumVersion = versions.maxVer
        self.includesUpperBound = versions.upperIncluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.name = try container.decode(String.self, forKey: .name)

        let versions = version.getMinMaxVersions()
        self.minimumVersion = versions.minVer
        self.maximumVersion = versions.maxVer
        self.includesUpperBound = versions.upperIncluded
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(name, forKey: .name)
    }

}

// TODO: Remove this
extension ProjectPackageRequest {
    static let mockList: [ProjectPackageRequest] = [
        ProjectPackageRequest(
            version: "1.2.3",
            name: "Underscore"
        ),
        ProjectPackageRequest(
            version: "1.2.3-2.1.0",
            name: "Lodash"
        ),
        ProjectPackageRequest(
            version: "^1.2.3",
            name: "React"
        )
    ]
}

struct FirestoreProjectPackage: Codable {
    @Firestore.StringValue
    var id: String

    @Firestore.StringValue
    var name: String

    @Firestore.StringValue
    var version: String

    // TODO: Update this to be an optional
    @Firestore.StringValue
    var content: String

    // TODO: Update this to be an optional
    @Firestore.StringValue
    var url: String

    func asProjectPackage() -> ProjectPackage {
        ProjectPackage(
            metadata: Metadata(
                name: name,
                version: version,
                id: id
            ),
            data: PackageData(
                content: content,
                url: url
            )
        )
    }
}

struct ProjectPackage: Content, Codable {
    let metadata: Metadata
    let data: PackageData

    func asFirestoreProjectPackage() -> FirestoreProjectPackage {
        FirestoreProjectPackage(
            id: metadata.id,
            name: metadata.name,
            version: metadata.version,
            content: data.content,
            url: data.url
        )
    }

    func asResponseBody() throws -> Response.Body {
        let data = try JSONEncoder().encode(self)
        return Response.Body(data: data)
    }
}

struct Metadata: Content, Codable {
    var name: String
    var version: String
    var id: String

    func asResponseBody() throws -> Response.Body {
        let data = try JSONEncoder().encode(self)
        return Response.Body(data: data)
    }

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case version = "Version"
        case id = "ID"
    }
}

struct PackageData: Codable {
    var content: String
    var url: String

    enum CodingKeys: String, CodingKey {
        case content = "Content"
        case url = "URL"
    }
}

// TODO: Remove this mock object
extension ProjectPackage {
    static let mock = ProjectPackage(
        metadata: Metadata(
            name: "Underscore",
            version: "1.0.0",
            id: "underscore"
        ),
        data: PackageData(
            content: "TEST_BASE_64_ENCODED_CONTENT_STRING",
            url: "https://github.com/jashkenas/underscore"
        )
    )

    static let temporary = ProjectPackage(
        metadata: Metadata(
            name: "Temporary",
            version: "1.0.0",
            id: "temporary"
        ),
        data: PackageData(
            content: "TEST_BASE_64_ENCODED_CONTENT_STRING",
            url: "https://github.com/test/temporary"
        )
    )

    static let doesNotExist = ProjectPackage(
        metadata: Metadata(
            name: "DoesNotExist",
            version: "1.0.0",
            id: "does_not_exist"
        ),
        data: PackageData(
            content: "TEST_BASE_64_ENCODED_CONTENT_STRING",
            url: "https://github.com/test/does_not_exist"
        )
    )
}

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
    
    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case name = "Name"
    }
    
    init(version: String, name: String) {
        self.version = version
        self.name = name
    
        let versions = ProjectPackageRequest.getMinMaxVersions(for: version)
        self.minimumVersion = versions.0
        self.maximumVersion = versions.1
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decode(String.self, forKey: .version)
        self.name = try container.decode(String.self, forKey: .name)
    
        let versions = ProjectPackageRequest.getMinMaxVersions(for: version)
        self.minimumVersion = versions.0
        self.maximumVersion = versions.1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(name, forKey: .name)
    }
    
    private static func getMinMaxVersions(for version: String) -> (String, String?) {
        // TODO: Add additional checks
        // TODO: Is "-" inclusive or exclusive?
        if version.contains("-") {
            // Range
            let splitted = version.split(separator: "-")
            return (String(splitted[0]), String(splitted[1]))
        } else if version.contains("^") {
            // Minimum w/o maximum
            return (String(version.dropFirst()), nil)
        } else {
            // Exact
            // Sanity check that only 3 elements exist (major, minor, patch)
            assert(version.split(separator: "0").count == 3, "Version produced improper value: \(version)")
            return (version, version)
        }
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
            metadata: ProjectPackage.Metadata(
                name: name,
                version: version,
                id: id
            ),
            data: ProjectPackage.PackageData(
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

extension ProjectPackage {
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
            content: "UEsDBBQAAAAAADZVaVMAAAAAAAAAAAAAAAAFACAAdXVpZC9VVA0AB7iWimG4lophuJaKYXV4CwABBPcBAAAEFAAAAFBLAwQUAAgACAAkVWlTAAAAAAAAAAB6AQAAFgAgAHV1aWQvYmFiZWwuY29uZmlnLmpzb25VVA0AB5SWimGUlophlJaKYXV4CwABBPcBAAAEFAAAAKvmUlBQKihKLU4tKVayUoiO1QEL5JSmZ+YhCaTmlQE51UAmkJOcn5ubn5dVDBdBNSJaySEpMSk1Rx8ipgvSq6NQraBUkliUDlED5OTlp6QCWUoWSgq1OgpKufkppTmpIDmE8Qq1sbFg82t1IBanFuc6FeWXF6cWkWo1wvi0xJziVGwm+0EcRAMfoVnJBcK1XABQSwcIiFTUlZEAAAB6AQAAUEsDBBQACAAIACRVaVMAAAAAAAAAAFUEAAAPACAAdXVpZC9MSUNFTlNFLm1kVVQNAAeUlophlJaKYZSWimF1eAsAAQT3AQAABBQAAABdUltv2jAUfudXHPHUSlnH+rg3k5hiNcSRY8p4DIlDPIUY2WaIf79jk67tJCQ4t+9mZK9gwyTkulGjU/CAxeNslprzzepj7+GheYTnxY/Ft+fF8wKEOSjr4VWrrlMW6rEF43v81ZjRW324eGPdbFYqe9LOaTOCdoBzdbjB0dajV20CnVUKTAdNX9ujSsAbBLrBWVmHB+bgaz3q8Qg1op5vYdP3CONM56+1VZG1ds40ukY8aE1zOanR1z7wdXpQDh5QFMyr6WL+GElaVQ+gRwiz9xFcte/NxYNVDg00ASPBpWa4tEHD+3jQJz0xhPOYjQugF4cOgs4ETqbVXfhW0db5chi06xNotbtng00XmjHqJPj4biw4NQwBQaPu6PVDXdwJLOcQqJ8iirzX3py+OsGIuosdkVLFm9ZgZJHxt2p86IT1zgyDuQZr+GStDo7cz9lM4qg+mD8qerk//Wg8Sr1LCA9w/njVaeT6GrUf1BQY8mK89Sc7NtA7jw+vMfuzsZHvf5tPyL+mUPGV3BFBgVVQCv7GMprBnFRYzxPYMbnmWwm4IUgh98BXQIo9vLIiS4D+KgWtKuAC2KbMGcUeK9J8m7HiBZZ4V3D8lzP8eyOo5BAIJyhGqwC2oSJdY0mWLGdyn8CKySJgrhCUQEmEZOk2JwLKrSh5RZE+Q9iCFSuBLHRDC/mErNgD+oYFVGuS55GKbFG9iPpSXu4Fe1lLWPM8o9hcUlRGljm9U6GpNCdsk0BGNuSFxiuOKCKuTep2axpbyEfwk0rGi2Aj5YUUWCboUsh/pztW0QSIYFUIZCU4woc48YJHELwr6B0lRA1fXgRXQr2t6IeWjJIcsapw/Hn5afYXUEsHCLhJGDGDAgAAVQQAAFBLAwQUAAgACAA2VWlTAAAAAAAAAAAEGAAADgAgAHV1aWQvLkRTX1N0b3JlVVQNAAe4lophuJaKYbiWimF1eAsAAQT3AQAABBQAAADtmDsOwjAQRGeNC0s0LindcABuYEXJCbgABVeg99Eh2hGyFFJQJYJ5kvVWin9pHE8A2PC4X4AMIMGNMz6S2BaErjbOIYQQQoh9Y6503HYbQogdMp8Pha50cxufBzp2YzJd6Eo3t7FfoCOd6EwXutLNzUPLGD6MKxsTijGFWKHrV68sxN9wcOX5+z9hNf8LIX4Yi+N1HPAOBMsOr3br6ob1S0Dwn4WnbmyhK93cuggIsRVPUEsHCGoAiG2yAAAABBgAAFBLAwQUAAgACAA2VWlTAAAAAAAAAAB4AAAAGQAgAF9fTUFDT1NYL3V1aWQvLl8uRFNfU3RvcmVVVA0AB7iWimG4lophuZaKYXV4CwABBPcBAAAEFAAAAGNgFWNnYGJg8E1MVvAPVohQgAKQGAMnEBsBsRsQg/gVQMwAU+EgwIADOIaEBEGZFTBd6AAAUEsHCAuIwDg1AAAAeAAAAFBLAwQUAAAAAAAkVWlTAAAAAAAAAAAAAAAACgAgAHV1aWQvdGVzdC9VVA0AB5SWimG5lophlJaKYXV4CwABBPcBAAAEFAAAAFBLAwQUAAgACAAkVWlTAAAAAAAAAACIMQAAEQAgAHV1aWQvQ0hBTkdFTE9HLm1kVVQNAAeUlophlJaKYZSWimF1eAsAAQT3AQAABBQAAADdW82OGzmSvvspuDCwLmEsFX+SzMzuncG43dU9tTs2Gl3jvhQWMH9LaUuZmsyUqtSLOc877GmP+1zzJBskM7OkstxFYbGXRQNuWQqSwWDEF18E6Zfo7VLWd3bV3L148Wa1QnXTS7WySIevO9Q3qF9WHdq0zSere3RfgZCyyDR6u7Z1bw2q6ijiqpVdoBtr0W3Xy9rI1sx3tu2qpv73i2Xfb7pvLi/vqn65VQvdrC91U+9gBvhZruZ6VOPy6dgZck2LYMC66tHdtjJ2VdW2W7x48fLlS3RbLNiCnpx/C7KfuvA/WGu9ka293Hlxslgswgc6QxcUUzwndI6LWZzxu+0d+qF6sN2LF3O0kr/u0aqRBt3Z/mdQrFn/IldbMMzF7UvO8mcXrroOpC9BdAaL3RKhCydMir6w3ctB3FEnFC5VZgRlXGBqhOQlIUXBKJYFtbPZa6RXTQd6ebVEulpidmBHcp4d8WhHMtkRz3F2yo7ddrNp2h7Zh03zh9+zEsbiYELCk3UlPJhQCy6xY6kmHMSdzJkqMSl5aQQrDLEMLGic1EZZU4j8yIQsT1YLRMOGowXxORakjxbEowVxPqf5YMEfrOy3bTSgNAbBuM5CfLRVfVe5/eVOrioje5grRsrl++s/ozc/XQfnzPIydQsgGiyLrdAEq1TLDuKSKFdykuelcI4yjTl1GmeisNY4w112ZNks3bIgOgsjivQRRRhRPH8M44gCxxHPu/40gvgRJH0NEJ08hJ7nIWT0EHrgIWJO2QkPqdaA0TuLNrYFwFzLWlvUOLQjKHoMau0GRAFxpcfc4CP8+TAat83Z4CMWK/E87k0+EsQ1y4tMcFpqIXBRFgXOSGZo6Zi0hFEDkQ07aO3ab8B4PbX0qWWXjcqDReTa9raNemfpemdB76LQlmmZqvcgDt4NnuxAZy6MFVTn2mLmciXLQslM6GPfTs8HIDo7gMVP3WYdgzb9QPJ4ILZ0lBfJBzKIy5LynGupGVGamEzaMsssyTUucy4EB0A4geJwLt4z4TD0Z3lnA5q3fRcS9L1V/mvEwz5EesyKIh6QERayWvIBRXFXlAK2UcJmLKTHktqylBnLGOCO5IUsZlPokfNCD4+hRw5Cj88p/o3QA3c9jD61B5fediH2AnVA9XatwIVl28p9sBNLR0MW05+CjTmczCAG8ZwQMA+1BjNDXJ45Q6g04N6yyI3OSxMCsNn01br61aJfiqcwova97f7SfICpo+LpEchiBFrCRZaQ7kdHjeJZVlhNJCQWThzEowAA0U5RcGJS5sTRk44aHXP008WnDvCutX/dVi2ASjgWqft5DUAIpwZHg9S2NivIomFvWXrmzGLmVJYAUbPJhxLFSwn0TWjGC4sxLxUkTulMTgmTMiskp4foIqvLWtaN9ZS5Ax1PrnUk9Kjky/DJLw7fz4E/YoIhRkLm+8pMJzebTcGEzwmmHMRZDCZ8EEzZnJbD4f3jP/8Lfffz1Zt/u37/I3r7pzfvf7y68ef4AwDLcEpXb9+9udFttenRu8ZsoUS5uLp5N0PbziMR1CDvG+NPGjX1ag+D1nDSIz55zPKfO2teQ61i4a9Qr9QNWjetzzdOblf9IA11BUIfP340lXPwaQ6x7V3J7wi5FmL4lf/46lv/G1QwXQNFD5QtF/7bxS67mM2+RZeXaP4H9EobOFyFizmWRs8zl6m5FNbNGeSTXBJdFqJ8BfP8bljjPzyAyC6sBZ/+9nS938UfLuIK//j7f6NXpSLGA9+cqdzMMyXNvFTGzKmCmFfMaCXMq7ghb8/vrd0MgeBRqdtYXblKI7m6a1o4xXXnYz1Uc6tKtbKF4qf6bNHHIXgugjKXu+zV7ONrdL+s9BItQWNlbX2Yt+E4PnrJP+YgFk29aqC+a8eMZ02w83Xd9RaKq21n/bk8ObZ+KfuozDqe+PBDGOpd4wuf6KJTfPP1MwS7PlrVb+TbMw5gsv9o0ajGWwispv7Xm6fLeveYVv09+tKGYe0o5Zf+5nHhJ9JR9Ivln+ahIVTGSLi6eTTLfSs3G596NpCqpF7OAtLRdLpBI92gpnS8TAp+j3SDuDRljokRJRWUa5xbKGQdhrqsJJTmZUmOeBTNkrMiiAYUI+mQTUo/gmXPNw3GCi+jR+x0CqHYBchocrkNosGIRrqcqucp0mDEQTzTVgFy5lQWRCnuIM4V5sZASUupVkqeTIW+cBwdFHV7YP8PEEdyvYF46hsEoPv9uysE29Gfu15CEHRWT/UBSSe0JDY4LLa6yJL9YxAHYi1NlqncOgyVBmZCC0IdN4oT5ozE49ZuQy45L/VQn3rCuCn1sDkjp4y1lp+PT3gCNW+Re9nWHjbvm/azhzjVNvfdSBpwugfiSBpgu4TgZOY+iJtCYyByjotCEAtFSQYFiS4N0AhJrFDuuCTB6UR86oAFI5/RU/PiZDQyPTDy6V5QMLLU2nahvbju3rb7DXzwQFhBPqh7b1BWJmMTiMYSQjkqabLvDeKOccENcGJmJHAvbq0ykEdlaahxhBQ6UOMOUsSqcj4f1uHwTzlGUDu5k8A87HnyqKgu7PM0bCSPURwKuUxzV2pipXTMSg50GGvBmDYl1ioPam83vkEUlI7Glj2kbLB0MHPlWbE0axs0L5JxDESjB2eOuoRhowdHcQuWVcqRzFrusMMY0E0yowiF9CCEyY6C/YyeZD4WbWHc5Id0TvkpP9QrK2uwELLdGgqAamViJVtD+oxFQYzvaJx0byyiN/ISCtSEUmIwziBuc22BuNnCKfBMsBBVpZHSgolcJqBWC8fqy80KtBw1HBqAHZwo+KWFP+B0A3kZmFO3h8Bax50kN65ANB4zyzJJkwAhHHMUt7m0hjFlC0Fz650Uc2C+jnIhKcl9P+mo45oMVCA61CH5eXUIW2SP/oEP/SN7pg75y/JpmTCyX2CuxgeWigTW0zO0tv2y8TVlPwjdA6eUKx9qe2SqTjfbFoqWQJNBqYennPv1I6eOpAPI8hxdPQAA6ar31U3T28iOQ66K7HWg7qAo0E8oceqhaBl8A7ltHRJ7LIcOyLp39UeCbutJPf9DWOWAZw/+FIn6uHC3bLYr420QzFFFVr9AV/7KRp6ESh9oG9t4FnK/bMI+5mPOPd7EVJugnWwrWXv+P0c/Rzbmw7YHM46NND8tLG81UOInTZc7W9t",
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
            content: "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",
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
            content: "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",
            url: "https://github.com/test/does_not_exist"
        )
    )
}


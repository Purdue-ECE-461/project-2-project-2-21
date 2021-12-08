//
//  InternalError.swift
//  
//
//  Created by Charles Pisciotta on 12/4/21.
//

import Foundation
import Vapor

struct InternalError: Codable {
    let code: Int
    let message: String

    func asResponseBody() -> Response.Body {
        if let data = try? JSONEncoder().encode(self) {
            return Response.Body(data: data)
        } else {
            // This should never happen
            return Response.Body()
        }
    }
}

extension InternalError {
    static let packageRetrievalError = InternalError(
        code: -1,
        message: "An error occurred while retrieving package"
    )

    static let unexpectedError = InternalError(
        code: -1,
        message: "An unexpected error occurred"
    )
}

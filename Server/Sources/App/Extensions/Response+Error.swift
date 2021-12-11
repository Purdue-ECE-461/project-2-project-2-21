//
//  Response+Error.swift
//  
//
//  Created by Charles Pisciotta on 12/4/21.
//

import Foundation
import Vapor

extension Response {
    static var noSuchPackageError: Response {
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "application/json")

        return Response(
            status: .internalServerError,
            headers: headers,
            body: InternalError.packageRetrievalError.asResponseBody()
        )
    }
}

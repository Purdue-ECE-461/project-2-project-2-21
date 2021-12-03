//
//  ResetController.swift
//  
//
//  Created by Charles Pisciotta on 12/2/21.
//

import Foundation
import Vapor

struct ResetController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.group("reset") { route in
            route.delete(use: reset)
        }
    }
    
    func reset(req: Request) throws -> Response {
        // TODO: Implement reset
        
        var headers = HTTPHeaders()
        headers.add(name: .contentType, value: "text/plain")
        return Response(status: .ok, headers: headers)
    }
}

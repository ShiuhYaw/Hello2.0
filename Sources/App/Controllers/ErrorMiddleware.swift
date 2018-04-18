//
//  ErrorMiddleware.swift
//  App
//
//  Created by Shiuh Yaw Phang on 16/4/18.
//

import Foundation
import HTTP

enum FooError: Error {
    case fooServiceUnavailable
}

final class ErrorMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch FooError.fooServiceUnavailable {
            throw Abort(.badRequest, reason: "Sorry, we were unable to query the Foo Service")
        }
    }
}

extension FooError: Debuggable {
    var reason: String {
        return "You do not have a `foo`."
    }
    
    var identifier: String {
        return "DebuggingTests.FooError.noFoo"
    }
    
    var possibleCauses: [String] {
        return [""]
    }
    
    var suggestedFixes: [String] {
        return [""]
    }
}

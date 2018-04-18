//
//  VersionMiddleware.swift
//  App
//
//  Created by Shiuh Yaw Phang on 16/4/18.
//

import Foundation
import HTTP

final class VersionMiddleware: Middleware {
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let response = try next.respond(to: request)
        response.headers.version = "APU v1.0"
        return response
    }
}

extension HTTP.KeyAccessible where Key == HeaderKey, Value == String {
    
    var version: String? {
        get {
            return self["Version"]
        }
        set {
            self["Version"] = newValue
        }
    }
}

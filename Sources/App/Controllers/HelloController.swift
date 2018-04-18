//
//  HelloController.swift
//  App
//
//  Created by Shiuh Yaw Phang on 11/4/18.
//

import Foundation
import HTTP

final class HelloController {
    
    func sayHello(_ req: Request) throws -> ResponseRepresentable {
        guard let name = req.data["name"]?.string else {
            throw Abort(.badRequest)
        }
        return "Hello, \(name)"
    }
    
    func sayHelloAlternate(_ req: Request) throws -> ResponseRepresentable {
        let name: String = try req.parameters.next(String.self)
        return "Hello, \(name)"
    }
}

extension HTTP.KeyAccessible where Key == HeaderKey, Value == String {
    
    var customKey: String? {
        get {
            return self["Custom-Key"]
        }
        set {
            self["Custom-Key"] = newValue
        }
    }
}

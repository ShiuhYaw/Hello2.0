//
//  Token.swift
//  App
//
//  Created by Shiuh Yaw Phang on 12/4/18.
//

import Foundation
import FluentProvider

final class Token: Model {
    
    var token: String
    var userId: Identifier
    /// storage property to allow Fluent to store extra infomation on model-things like the model's database id.
    let storage = Storage()
    
    struct Keys {
        static let id = "id"
        static let token = "token"
        static let userId = "user_id"
    }
    
    init(token: String, userId: Identifier) {
        self.token = token
        self.userId = userId
    }
    
    init(row: Row) throws {
        token = try row.get(Token.Keys.token)
        userId = try row.get(Token.Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Token.Keys.token, token)
        try row.set(Token.Keys.userId, userId)
        return row
    }
}

extension Token {
    
    var owner: Parent<Token, User> {
        return parent(id: userId)
    }
}

extension Token: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(
            token: try json.get(Token.Keys.token),
            userId: try json.get(Token.Keys.userId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Token.Keys.id, id)
        try json.set(Token.Keys.token, token)
        try json.set(Token.Keys.userId, userId)
        return json
    }
}

extension Token: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set(Token.Keys.id, id)
        try json.set(Token.Keys.token, token)
        try json.set(Token.Keys.userId, userId)
        return try json.makeResponse()
    }
}

extension Token: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { (tokens) in
            tokens.id()
            tokens.string(Token.Keys.token)
            tokens.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

import HTTP

extension Token: Updateable {
    
    static var updateableKeys: [UpdateableKey<Token>] {
        return [
            UpdateableKey(Token.Keys.token, String.self) { object, token in
                object.token = token
            }
        ]
    }
}

extension Token: Timestampable { }

extension Token: SoftDeletable { }

extension Token: NodeInitializable {
    
    convenience init(node: Node) throws {
        self.init(
            token: try node.get(Token.Keys.token),
            userId: try node.get(Token.Keys.userId)
        )
    }
}

extension Token: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Token.Keys.id, id)
        try node.set(Token.Keys.token, token)
        try node.set(Token.Keys.userId, userId)
        return node
    }
}

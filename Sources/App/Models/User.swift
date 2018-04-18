//
//  User.swift
//  App
//
//  Created by Shiuh Yaw Phang on 11/4/18.
//

import Foundation
import FluentProvider

final class User: Model {
    
    let storage = Storage()
    var name: String
    var username: String
    var password: String
    var age: Int
    
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let username = "email"
        static let password = "password"
        static let age = "age"
        static let pets = "pets"
        static let tokens = "tokens"
    }
    
    init(name: String, username: String, password: String, age: Int) {
        self.name = name
        self.age = age
        self.username = username
        self.password = password
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.name, name)
        try row.set(User.Keys.age, age)
        try row.set(User.Keys.username, username)
        try row.set(User.Keys.password, password)
        return row
    }
    
    init(row: Row) throws {
        name = try row.get(User.Keys.name)
        age = try row.get(User.Keys.age)
        username = try row.get(User.Keys.username)
        password = try row.get(User.Keys.password)
    }
}

extension User {
    
    var pets: Children<User, Pet> {
        return children()
    }
    
    func pet() throws -> Pet? {
        return try children().first()
    }
    
    var tokens: Children<User, Token> {
        return children()
    }
    
    func token() throws -> Token? {
        return try children().first()
    }
}

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { (builder) in
            builder.id()
            builder.string(User.Keys.name)
            builder.string(User.Keys.username)
            builder.string(User.Keys.password)
            builder.int(User.Keys.age)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

extension User: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(User.Keys.name),
            username: try json.get(User.Keys.username),
            password: try json.get(User.Keys.password),
            age: try json.get(User.Keys.age)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        try json.set(User.Keys.username, username)
        try json.set(User.Keys.password, password)
        try json.set(User.Keys.age, age)
        try json.set(User.Keys.pets, try pets.all())
        try json.set(User.Keys.tokens, try tokens.all())
        return json
    }
}

extension User: ResponseRepresentable {
    
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set(User.Keys.id, id)
        try json.set(User.Keys.name, name)
        try json.set(User.Keys.username, username)
        try json.set(User.Keys.password, password)
        try json.set(User.Keys.age, age)
        try json.set(User.Keys.pets, try pets.all())
        try json.set(User.Keys.tokens, try tokens.all())
        return try json.makeResponse()
    }
}

import HTTP

extension User: Updateable {
    
    static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey(User.Keys.name, String.self) { user, name in
                user.name = name
            },
            UpdateableKey(User.Keys.username, String.self) { user, username in
                user.username = username
            },
            UpdateableKey(User.Keys.password, String.self) { user, password in
                user.password = password
            },
            UpdateableKey(User.Keys.age, Int.self) { user, age in
                user.age = age
            }
        ]
    }
}

extension User: Timestampable { }

extension User: SoftDeletable { }

import AuthProvider
extension User: TokenAuthenticatable {
    
    /// the token model that should be queried
    /// to authenticate this user
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable { }

extension User: SessionPersistable { }

extension Request {
    
    func authedUser() throws -> User {
        return try auth.assertAuthenticated()
    }
}

extension User: NodeInitializable {
    
    convenience init(node: Node) throws {
        self.init(
            name: try node.get(User.Keys.name),
            username: try node.get(User.Keys.username),
            password: try node.get(User.Keys.password),
            age: try node.get(User.Keys.age)
        )
    }
}

extension User: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(User.Keys.id, id)
        try node.set(User.Keys.name, name)
        try node.set(User.Keys.username, username)
        try node.set(User.Keys.password, password)
        try node.set(User.Keys.age, age)
        try node.set(User.Keys.pets, try pets.all())
        try node.set(User.Keys.tokens, try tokens.all())
        return node
    }
}


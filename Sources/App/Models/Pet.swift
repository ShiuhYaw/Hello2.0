//
//  Pet.swift
//  App
//
//  Created by Shiuh Yaw Phang on 12/4/18.
//

import Foundation
import FluentProvider

final class Pet: Model {
    
    var name: String
    var age: Int
    var userId: Identifier
    /// storage property to allow Fluent to store extra infomation on model-things like the model's database id.
    let storage = Storage()

    struct Keys {
        static let id = "id"
        static let name = "name"
        static let age = "age"
        static let userId = "user_id"
    }
    
    init(name: String, age: Int, userId: Identifier) {
        self.name = name
        self.age = age
        self.userId = userId
    }
    

    init(row: Row) throws {
        name = try row.get(Pet.Keys.name)
        age = try row.get(Pet.Keys.age)
        userId = try row.get(Pet.Keys.userId)
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Pet.Keys.name, name)
        try row.set(Pet.Keys.age, age)
        try row.set(Pet.Keys.userId, userId)
        return row
    }
    
}

extension Pet {
    
    var owner: Parent<Pet, User> {
        return parent(id: userId)
    }
    
    var toys: Siblings<Pet, Toy, Pivot<Pet, Toy>> {
        return siblings()
    }
}

extension Pet: JSONConvertible {
    
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Pet.Keys.name),
            age: try json.get(Pet.Keys.age),
            userId: try json.get(Pet.Keys.userId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Pet.Keys.id, id)
        try json.set(Pet.Keys.name, name)
        try json.set(Pet.Keys.age, age)
        try json.set(Pet.Keys.userId, userId)
        return json
    }
}

extension Pet: ResponseRepresentable {
    
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set(Pet.Keys.id, id)
        try json.set(Pet.Keys.name, name)
        try json.set(Pet.Keys.age, age)
        try json.set(Pet.Keys.userId, userId)
        return try json.makeResponse()
    }
}

extension Pet: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { (pets) in
            pets.id()
            pets.string(Pet.Keys.name)
            pets.int(Pet.Keys.age)
            pets.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

import HTTP

extension Pet: Updateable {
    
    static var updateableKeys: [UpdateableKey<Pet>] {
        return [
            UpdateableKey(Pet.Keys.name, String.self) { user, name in
                user.name = name
            },
            UpdateableKey(Pet.Keys.age, Int.self) { user, age in
                user.age = age
            }
        ]
    }
}

extension Pet: Timestampable { }

extension Pet: SoftDeletable { }

extension Pet: NodeInitializable {
    
    convenience init(node: Node) throws {
        self.init(
            name: try node.get(Pet.Keys.name),
            age: try node.get(Pet.Keys.age),
            userId: try node.get(Pet.Keys.userId)
        )
    }
}

extension Pet: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Pet.Keys.id, id)
        try node.set(Pet.Keys.name, name)
        try node.set(Pet.Keys.age, age)
        try node.set(Pet.Keys.userId, userId)
        return node
    }
}


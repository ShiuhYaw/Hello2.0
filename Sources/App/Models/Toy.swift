//
//  Toy.swift
//  App
//
//  Created by Shiuh Yaw Phang on 12/4/18.
//

import Foundation
import FluentProvider

final class Toy: Model {
    
    var name: String
    /// storage property to allow Fluent to store extra infomation on model-things like the model's database id.
    let storage = Storage()
    
    struct Keys {
        static let id = "id"
        static let name = "name"
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(Toy.Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Toy.Keys.name, name)
        return row
    }
}

// MARK: Fluent Preparation

extension Toy: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Toy.Keys.name)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Toy: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Toy.Keys.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Toy.Keys.id, id)
        try json.set(Toy.Keys.name, name)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Toy: ResponseRepresentable {
    func makeResponse() throws -> Response {
        var json = JSON()
        try json.set(Toy.Keys.id, id)
        try json.set(Toy.Keys.name, name)
        return try json.makeResponse()
    }
}

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Toy: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Toy>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Toy.Keys.name, String.self) { toy, name in
                toy.name = name
            }
        ]
    }
}

extension Toy: NodeInitializable {
    
    convenience init(node: Node) throws {
        self.init(
            name: try node.get(Toy.Keys.name)
        )
    }
}

extension Toy: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set(Toy.Keys.id, id)
        try node.set(Toy.Keys.name, name)
        return node
    }
}

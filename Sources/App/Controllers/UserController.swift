//
//  UserController.swift
//  App
//
//  Created by Shiuh Yaw Phang on 11/4/18.
//

import Foundation
import Vapor
import HTTP

final class UserController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        
        return try User.all().makeJSON()
    }
    
    func store(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.user()
        try user.save()
        return user
    }
    
    func show(_ req: Request, user: User) throws -> ResponseRepresentable {
        return user
    }
    
    func delete(_ req: Request, user: User) throws -> ResponseRepresentable {
        try user.delete()
        return Response(status: .ok)
    }
    
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try User.makeQuery().delete()
        return Response(status: .ok)
    }
    
    func update(_ req: Request, user: User) throws -> ResponseRepresentable {
        try user.update(for: req)
        try user.save()
        return user
    }
    
    func replace(_ req: Request, user: User)throws -> ResponseRepresentable {
        let new = try req.user()
        user.name = new.name
        try user.save()
        return user
    }
    
    func makeResource() -> Resource<User> {
        return Resource(index: index,
                        store: store,
                        show: show,
                        update: update,
                        replace: replace,
                        destroy: delete,
                        clear: clear)
    }
}

extension Request {
    
    func user() throws -> User {
        guard let json = json else { throw Abort.badRequest }
        return try User(json: json)
    }
}

extension UserController: EmptyInitializable { }

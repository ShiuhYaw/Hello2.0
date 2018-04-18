//
//  V1Collection.swift
//  App
//
//  Created by Shiuh Yaw Phang on 11/4/18.
//

import Foundation
import HTTP
import Routing

class V1Collection: RouteCollection, EmptyInitializable {
    
    required init() {
        
    }
    func build(_ builder: RouteBuilder) throws {
        let v1 = builder.grouped("v1")
        let users = v1.grouped("users")
        let articles = v1.grouped(host: "articles")
        
        users.get { (req) -> ResponseRepresentable in
            return "Requested all users."
        }
//        articles.get(Article.init) { request, article in
//            return "Requested \(article.name)"
//        }
    }
}

import Vapor
import LeafProvider
import MySQLProvider
import AuthProvider
import Sessions

extension Droplet {
    func setupRoutes() throws {
        
        get("welcome") { req in
            return "Hello"
        }
        
        post("form") { req in
            return "Submitted with a POST request"
        }
        
        get("foo", "bar", "baz") { req in
            return "You requested /foo/bar/baz"
        }
        
        get("vapor") { req in
            return Response(redirect: "http://vapor.codes")
        }
        
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
        
        get("html") { req in
            return try self.view.make("index.html")
        }
        
        get("template") { req in
            return try self.view.make("welcome", [
                "message": "Hello, world!"
            ])
        }
        let hc = HelloController()
        get("hello", handler:hc.sayHello)
        get("hello", String.parameter, handler: hc.sayHelloAlternate)
        
        let users = UserController()
        resource("users", users)
        
        let name = config["keys", "test-names", 0]?.string ?? "default"
        debugPrint("name: \(name)")
        
        let mongoURL = config["keys", "mongo", "url"]?.string ?? "default"
        debugPrint("mongoURL: \(mongoURL)")
        
        get("version") { request in
            var json = JSON()
            try json.set("version", 1.0)
            return json
        }
        
        get("users", Int.parameter) { req in
            let userId = try req.parameters.next(Int.self)
            guard let user = try User.find(userId) else {
                throw Abort.notFound
            }
            return "you requested User #\(userId)"
        }
        
        get("users", User.parameter) { req in
            let user = try req.parameters.next(User.self)
            return try user
        }
        
        post("users") { req in
            guard let json = req.json else {
                throw Abort.badRequest
            }
            let user = try User(json: json)
            try user.save()
            return user
        }
        
        get("json") { req in
            var json = JSON()
            try json.set("number", 123)
            try json.set("text", "unicorns")
            try json.set("bool", false)
            return json
        }
        
        get("404") { req in
            throw Abort.notFound
        }
        
        get("error") { req in
            throw Abort(.badRequest, reason: "Sorry 😱")
        }
        
        get("anything", "*") { req in
            return "Matches anything after /anything"
        }
        
        let userGroup = grouped("users", User.parameter)
        userGroup.get("messages") { req in
            
            let user = try req.parameters.next(User.self)
            return user
        }
        
        group("v1") { v1 in
            v1.get("users") { (req) -> ResponseRepresentable in
                let user = try req.parameters.next(User.self)
                return user
            }
        }
        
        let v1 = grouped("v1")
        v1.get("users") { (req) -> ResponseRepresentable in
            let user = try req.parameters.next(User.self)
            return user
        }
        grouped(host: "vapor.codes").grouped(DateMiddleware()).group("v1") { (authedSecureV1) in
        }
        
        let v1Collection = V1Collection()
        try! collection(v1Collection)
        
        try! collection(V1Collection.self)
        
        try cache.set("hello", "world")
        try cache.set("ephemeral", 42, expiration: Date(timeIntervalSinceNow: 30))
        try cache.get("hello")
        try cache.delete("hello")
        
        let mysqlDriver = try mysql()
        let result = try mysqlDriver.raw("SELECT @@version")
        try mysqlDriver.transaction { (conn) in
            let user = User(name: "Bob",
                            username:"vapor",
                            password: "foo",
                            age: 32)
            try user.save()
            let digest = try hash.make(user.id!.string!)
            let token = Token(token: digest.makeString(),
                              userId: try user.assertExists())
            try token.save()
        }
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        authed.get("me") { (req) -> ResponseRepresentable in
            
            return try req.authedUser()
        }
        
        let memory = MemorySessions()
        let redirect = RedirectMiddleware.login()
        let inverseRedirect = InverseRedirectMiddleware.home(User.self)
        let sessionMiddleware = SessionsMiddleware(memory)
        let persistMiddleware = PersistMiddleware(User.self)
        let passwordMiddleware = PasswordAuthenticationMiddleware(User.self)
        let passwordAuthed = grouped([redirect, inverseRedirect, sessionMiddleware, persistMiddleware, passwordMiddleware])
        passwordAuthed.get("password", "me") { (req) -> ResponseRepresentable in
            
            return try req.authedUser()
        }
        passwordAuthed.get("login") { (req) -> ResponseRepresentable in
            return "Please login"
        }
        passwordAuthed.get("secure") { (req) -> ResponseRepresentable in
            let user = try req.auth.assertAuthenticated(User.self)
            return "Welcom to the secure page, \(user.name)"
        }
        post("remember") { req in
            guard let name = req.data["name"]?.string else {
                throw Abort.badRequest
            }
            let session = try req.assertSession()
            try session.data.set("name", name)
            return "Remember name"
        }
        get("remember") { req in
            let session = try req.assertSession()
            guard let name = session.data["name"]?.string else {
                throw Abort(.badRequest, reason: "Please POST the name first")
            }
            return name
        }
        get("response") { (req) -> ResponseRepresentable in
            let response = Response(status: .ok, body: "")
            return response
        }
        get("chunker") { (req) -> ResponseRepresentable in
            return Response(status: .ok) { (chunker) in
                for name in ["joe", "pam", "chery;"] {
                    sleep(1)
                    try chunker.write(name)
                }
                try chunker.close()
            }
        }
    }
}

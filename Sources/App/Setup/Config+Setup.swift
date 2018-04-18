import FluentProvider
import LeafProvider
import MySQLProvider
import RedisProvider
import AuthProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
        try setupConfiguration()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(RedisProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(User.self)
        preparations.append(Pet.self)
        preparations.append(Token.self)
        preparations.append(Post.self)
        preparations.append(Toy.self)
        preparations.append(Pivot<Pet, Toy>.self)
    }

    /// Configure Custom Logger
    private func setupConfiguration() throws {
        
        addConfigurable(log: AllCapsLogger.init, name: "all-caps")
        addConfigurable(command: MyCustomCommand.init, name: "my-command")
        addConfigurable(middleware: VersionMiddleware(), name: "version")
        addConfigurable(middleware: ErrorMiddleware(), name: "error")
        addConfigurable(middleware: CORSMiddleware(), name: "cors")
    }
}

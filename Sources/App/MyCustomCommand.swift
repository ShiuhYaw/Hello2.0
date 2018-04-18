//
//  MyCustomCommand.swift
//  App
//
//  Created by Shiuh Yaw Phang on 11/4/18.
//

import Foundation
import Vapor
import Console

final class MyCustomCommand: Command {
    
    /// "id" property is the string that will tyep in the console to access the command.
    /// ".build/debug/App command" will run the Custom Command.
    let id: String = "my-command"
    
    /// "help" property is the help message that will give custom command's users some idea of how to access it
    let help = [
        "This command does things, like foo, and bar."
    ]
    
    /// "console" property is the object passed to custom command that adheres to the console protocol, allowing manipulation of the console.
    let console: ConsoleProtocol
    
    init(console: ConsoleProtocol) {
        self.console = console
    }
    
    /// "run" method is where your put the logic relating to command
    func run(arguments: [String]) throws {
        console.print("running custom command...")
    }
}

extension MyCustomCommand: ConfigInitializable {
    
    convenience init(config: Config) throws {
        let console = try config.resolveConsole()
        self.init(console: console)
    }
}

//
//  AllCapsLogger.swift
//  App
//
//  Created by Shiuh Yaw Phang on 10/4/18.
//

import Foundation
import Vapor

final class AllCapsLogger: LogProtocol {
    var enabled: [LogLevel] = []
    let exclamationCount: Int
    
    init(exclamationCount: Int) {
        self.exclamationCount = exclamationCount
    }
    
    func log(_ level: LogLevel, message: String, file: String, function: String, line: Int) {
        debugPrint(message.uppercased() + String(repeating: "!", count: exclamationCount))
    }
}

extension AllCapsLogger: ConfigInitializable {
    
    convenience init(config: Config) throws {
        let count = config["allCaps", "exclamationCount"]?.int ?? 3
        self.init(exclamationCount: count)
    }
}

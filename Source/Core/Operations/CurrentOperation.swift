//
//  CurrentOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class CurrentOperation: GitIdentityOperation<String> {
    override func execute() throws -> String {
        let current = try CurrentIdentity(config: config)
        return current.targetName
    }

    override func printSuccess(_ value: String) {
        print("   \(value)")
    }
}

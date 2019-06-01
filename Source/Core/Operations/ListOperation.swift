//
//  ListOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class ListOperation: GitIdentityOperation<[String: Bool]> {
    override func execute() throws -> [String: Bool] {
        let current = try CurrentIdentity(config: config).targetName
        let identities = Identity.identities(config: config)

        var result = [String: Bool]()
        for id in identities {
            let name = id.name
            result[name] = (name == current)
        }

        return result
    }

    override func printSuccess(_ value: [String : Bool]) {
        for identity in value.keys.sorted() {
            let prefix = value[identity] ?? false
                ? " * "
                : "   "

            print("\(prefix)\(identity)")
        }
    }
}

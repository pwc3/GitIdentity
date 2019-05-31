//
//  main.swift
//  git-identity
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import GitIdentityCore
import Foundation

func main(args: [String]) throws -> Int32 {
    let config = Configuration()
    let identities = Identity.identities(config: config).map { $0.debugDescription }
    print(identities.joined(separator: "\n"))

    let current = try CurrentIdentity(config: config)
    print(current.debugDescription)

    return 0
}

do {
    exit(try main(args: CommandLine.arguments))
}
catch {
    print(error)
    exit(255)
}

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

    switch ActionParser.parse(arguments: Array(args[1...])) {
    case .success(let action):
        let operation = action.createOperation(config: config)
        operation.main()

    case .failure(let error):
        throw error
    }

    return 0
}

do {
    exit(try main(args: CommandLine.arguments))
}
catch {
    print(error)
    exit(255)
}

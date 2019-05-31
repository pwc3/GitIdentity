//
//  Action.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public enum Action: Equatable {

    case current

    case list

    case print

    case use(identity: String)

    case help

    public func createOperation(config: Configuration) -> Operation {
        switch self {
        case .current:
            return CurrentOperation(config: config, printOutput: true)

        case .list:
            return ListOperation(config: config, printOutput: true)

        case .print:
            return PrintOperation(config: config, printOutput: true)

        case .use(let identity):
            return UseOperation(config: config, printOutput: true, identity: identity)

        case .help:
            return HelpOperation(config: config, printOutput: true)
        }
    }
}

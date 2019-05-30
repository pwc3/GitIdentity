//
//  ActionParser.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public enum ActionParserError: Error, Equatable {

    case incorrectNumberOfArguments

    case unrecognizedCommand(String)
}

public struct ActionParser {

    public static func parse(arguments inputArguments: [String]) -> Result<Action, ActionParserError> {
        guard inputArguments.count > 0 else {
            return .failure(.incorrectNumberOfArguments)
        }

        let command = inputArguments[0]
        let arguments = Array(inputArguments[1...])

        switch command {
        case "current":
            return arguments.count == 0
                ? .success(.current)
                : .failure(.incorrectNumberOfArguments)

        case "list":
            return arguments.count == 0
                ? .success(.list)
                : .failure(.incorrectNumberOfArguments)

        case "print":
            return arguments.count == 0
                ? .success(.print)
                : .failure(.incorrectNumberOfArguments)

        case "use":
            return arguments.count == 1
                ? .success(.use(identity: arguments[0]))
                : .failure(.incorrectNumberOfArguments)

        default:
            return .failure(.unrecognizedCommand(command))
        }
    }
}

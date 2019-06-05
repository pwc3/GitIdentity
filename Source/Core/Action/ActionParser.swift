//
//  ActionParser.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright (C) 2018-2019 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation

/**
 Parses the command-line arguments, returning an `Action` value that can be used to create an `Operation` to execute the selected command
 */
public struct ActionParser {

    /**
     Parses the specified arguments array. Note that if this is taken directly from the command line (i.e., from `CommandLine.arguments`), the first element (containing the application name) must be stripped off before passing to this function.

     - Parameter arguments: A string array containing the command and any optional argument.
     - Returns: A `Result` indicating success (with an associated `Action` value) or error (with an associated `GitIdentityError` value).
     */
    public static func parse(arguments inputArguments: [String]) -> Result<Action, GitIdentityError> {
        guard inputArguments.count > 0 else {
            // Default to "list" if no arguments provided
            return .success(.list)
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

        case "help", "-h", "--help", "-?":
            return .success(.help)

        case "version":
            return .success(.version)

        default:
            return .failure(.unrecognizedCommand(command))
        }
    }
}

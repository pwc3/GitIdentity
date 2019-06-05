//
//  Action.swift
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
 Represents an action that can be performed by the command-line tool. This is the output of the `ActionParser` which is used to parse command-line arguments.
 */
public enum Action: Equatable {

    /// Print the current identity.
    case current

    /// List the available identities.
    case list

    /// Print information about the current identity.
    case print

    /// Change the current identity to use the specified identity.
    case use(identity: String)

    /// Print the version number.
    case version

    /// Print help information.
    case help

    /**
     Create an operation to execute this command.

     - Parameter config: the current configuration, passed to the appropriate operation's initializer.
     - Returns: An `Operation` to execute this command.
     */
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

        case .version:
            return VersionOperation(config: config, printOutput: true)

        case .help:
            return HelpOperation(config: config, printOutput: true)
        }
    }
}

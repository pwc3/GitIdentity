//
//  GitIdentityError.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/31/19.
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

/// Indicates an error condition detected by the application.
public enum GitIdentityError: Error {

    /// Indicates that the expected number of arguments was not provided.
    case incorrectNumberOfArguments

    /// Indicates that the specified command is not recognized.
    case unrecognizedCommand(String)

    /// Indicates that the file at the specified path does not exist.
    case fileNotFound(atPath: String)

    /// Indicates that the file at the specified path is not a symbolic link.
    case fileIsNotSymbolicLink(atPath: String)

    /// Indicates that the `current` identity is not defined in the configuration file.
    case currentIdentityNotDefined

    /// Indicates that the files referenced by the `current` identity's symbolic links do not match any of the identities in the configuration.
    case currentIdentityNameNotFound

    /// The specified identity is not defined.
    case identityNotFound(name: String)
}

extension GitIdentityError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .incorrectNumberOfArguments:
            return "Incorrect number of arguments"

        case .unrecognizedCommand(let command):
            return "Unrecognized command: \"\(command)\""

        case .fileNotFound(let path):
            return "File not found at \(path)"

        case .fileIsNotSymbolicLink(let path):
            return "Expected symbolic link at \(path)"

        case .currentIdentityNotDefined:
            return "The configuration file does not specify a \"current\" configuration defining the symbolic link locations."

        case .currentIdentityNameNotFound:
            return "The files referenced by the \"current\" identity's symbolic links do not match any identities defined in the configuration file."

        case .identityNotFound(let name):
            return "Could not find identity with name \"\(name)\""
        }
    }
}

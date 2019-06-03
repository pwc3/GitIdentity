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

public enum Action: Equatable {

    case current

    case list

    case print

    case use(identity: String)

    case version

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

        case .version:
            return VersionOperation(config: config, printOutput: true)

        case .help:
            return HelpOperation(config: config, printOutput: true)
        }
    }
}

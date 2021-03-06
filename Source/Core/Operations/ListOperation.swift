//
//  ListOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
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

/// Operation to get the supported identities. The resulting dictionary maps from identity name to a boolean value indicating whether the associated identity is the current identity.
public class ListOperation: GitIdentityOperation<[String: Bool]> {

    override func execute() throws -> [String: Bool] {
        let current = try config.loadCurrentIdentity().name
        let identities = config.identityNames

        var result = [String: Bool]()
        for id in identities {
            result[id] = (id == current)
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

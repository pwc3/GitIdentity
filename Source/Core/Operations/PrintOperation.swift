//
//  PrintOperation.swift
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

public class PrintOperation: GitIdentityOperation<(current: String, gitconfig: String, publicKey: String)> {

    override func execute() throws -> (current: String, gitconfig: String, publicKey: String) {
        let current = try CurrentIdentity(config: config)

        let gitconfig = try current.target.gitconfigFile.readContents().trimmingCharacters(in: .newlines)
        let publicKey = try current.target.publicKeyFile.readContents().trimmingCharacters(in: .newlines)

        return (current: current.target.name, gitconfig: gitconfig, publicKey: publicKey)
    }

    override func printSuccess(_ value: (current: String, gitconfig: String, publicKey: String)) {
        let lines = [
            "Current Git identity: \(value.current)",
            "",
            "Git config contents:",
            "--------------------",
            value.gitconfig,
            "",
            "Public key:",
            "-----------",
            value.publicKey,
        ]
        print(lines.joined(separator: "\n"))
    }
}

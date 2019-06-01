//
//  PrintOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
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

//
//  HelpOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class HelpOperation: GitIdentityOperation<[String]> {

    override func execute() throws -> [String] {
        return [
            "git-identity: Manages multiple Git identity configurations (SSH keys, .gitconfig files).",
            "",
            "Commands:",
            " * git identity current",
            "     prints the current identity",
            " * git identity list",
            "     lists the available identities",
            " * git identity print",
            "     prints information about the current identity",
            " * git identity use NAME",
            "     changes the current identity to NAME",
            " * git identity help",
            "     prints this message"
        ]
    }

    override func printSuccess(_ value: [String]) {
        print(value.joined(separator: "\n"))
    }
}

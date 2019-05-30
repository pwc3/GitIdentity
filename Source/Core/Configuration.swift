//
//  Configuration.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public struct Configuration {

    public var sshPath: String

    public var gitconfigPath: String

    public init() {
        self.init(sshPath: NSString("~/.ssh").expandingTildeInPath,
                  gitconfigPath: NSString("~").expandingTildeInPath)
    }

    public init(sshPath: String, gitconfigPath: String) {
        self.sshPath = sshPath
        self.gitconfigPath = gitconfigPath
    }
}

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

    public static let defaultSshPath = NSString("~/.ssh").expandingTildeInPath

    public static let defaultGitconfigPath = NSString("~").expandingTildeInPath

    public init(sshPath: String = defaultSshPath, gitconfigPath: String = defaultGitconfigPath) {
        self.sshPath = sshPath
        self.gitconfigPath = gitconfigPath
    }
}

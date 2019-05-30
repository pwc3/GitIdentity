//
//  Identity.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class Identity {

    public static let currentIdentityName = "current"

    public let privateKeyFile: IdentityFile

    public let publicKeyFile: IdentityFile

    public let gitconfigFile: IdentityFile

    public let name: String

    public init(name: String, config: Configuration) {
        self.name = name
        self.privateKeyFile = IdentityFile(type: .privateKey, inDirectory: config.sshPath, forIdentity: name)
        self.publicKeyFile = IdentityFile(type: .publicKey, inDirectory: config.sshPath, forIdentity: name)
        self.gitconfigFile = IdentityFile(type: .gitconfig, inDirectory: config.gitconfigPath, forIdentity: name)
    }

    public static func identities(config: Configuration) throws -> [Identity] {
        let sshFiles = try IdentityFile.files(inDirectory: config.sshPath)
        let gitconfigFiles = try IdentityFile.files(inDirectory: config.gitconfigPath)

        let sshNames = Set(sshFiles.map { $0.identity })
        let gitconfigNames = Set(gitconfigFiles.map { $0.identity })

        let names = sshNames.intersection(gitconfigNames).subtracting([Identity.currentIdentityName])
        return names.map { Identity(name: $0, config: config) }
    }
}

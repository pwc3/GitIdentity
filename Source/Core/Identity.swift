//
//  Identity.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class Identity {

    public let name: String

    public let privateKeyFile: IdentityFile

    public let publicKeyFile: IdentityFile

    public let gitconfigFile: IdentityFile

    public static func read(name: String, config: Configuration) throws -> Identity {
        return Identity(name: name,
                        privateKeyFile: try IdentityFile(type: .privateKey, inDirectory: config.sshPath, forIdentity: name),
                        publicKeyFile: try IdentityFile(type: .publicKey, inDirectory: config.sshPath, forIdentity: name),
                        gitconfigFile: try IdentityFile(type: .gitconfig, inDirectory: config.gitconfigPath, forIdentity: name))
    }

    public init(name: String, privateKeyFile: IdentityFile, publicKeyFile: IdentityFile, gitconfigFile: IdentityFile) {
        self.name = name
        self.privateKeyFile = privateKeyFile
        self.publicKeyFile = publicKeyFile
        self.gitconfigFile = gitconfigFile
    }

    public static func identities(config: Configuration) -> [Identity] {
        let sshFiles = IdentityFile.files(inDirectory: config.sshPath)
        let gitconfigFiles = IdentityFile.files(inDirectory: config.gitconfigPath)

        let sshNames = Set(sshFiles.map { $0.identity })
        let gitconfigNames = Set(gitconfigFiles.map { $0.identity })

        let names = sshNames.intersection(gitconfigNames).subtracting([CurrentIdentity.identifier])
        return names.compactMap { try? Identity.read(name: $0, config: config) }
    }
}

extension Identity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Identity(name: \(name), privateKeyFile: \(privateKeyFile.debugDescription), publicKeyFile: \(publicKeyFile.debugDescription), gitconfigFile: \(gitconfigFile.debugDescription))"
    }
}

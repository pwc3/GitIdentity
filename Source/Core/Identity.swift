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

    public init(privateKeyFile: IdentityFile, publicKeyFile: IdentityFile, gitconfigFile: IdentityFile) throws {
        self.privateKeyFile = privateKeyFile
        self.publicKeyFile = publicKeyFile
        self.gitconfigFile = gitconfigFile

        let files = [privateKeyFile, publicKeyFile, gitconfigFile]
        let fileIdentities = Set(files.map { $0.identity })
        guard fileIdentities.count == 1, let name = fileIdentities.first else {
            throw GitIdentityError.inconsistentIdentities(files: files)
        }
        self.name = name

        _ = try filesAreAllSymlinks()
    }

    var files: [IdentityFile] {
        return [privateKeyFile, publicKeyFile, gitconfigFile]
    }

    func filesAreAllSymlinks() throws -> Bool {
        let isSymlink = files.map { $0.isSymlink }
        let allTrue = isSymlink.allSatisfy { $0 }
        let allFalse = isSymlink.allSatisfy { !$0 }

        if allTrue {
            return true
        }
        else if allFalse {
            return false
        }
        else {
            throw GitIdentityError.invalidIdentity(symlinks: files.filter { $0.isSymlink },
                                                   notSymlinks: files.filter { !$0.isSymlink })
        }
    }

    public static func read(name: String, config: Configuration) throws -> Identity {
        return try Identity(privateKeyFile: try IdentityFile(type: .privateKey,
                                                             inDirectory: config.sshPath,
                                                             forIdentity: name),
                            publicKeyFile: try IdentityFile(type: .publicKey,
                                                            inDirectory: config.sshPath,
                                                            forIdentity: name),
                            gitconfigFile: try IdentityFile(type: .gitconfig,
                                                            inDirectory: config.gitconfigPath,
                                                            forIdentity: name))
    }

    public static func identities(config: Configuration) -> [Identity] {
        let sshFiles = IdentityFile.files(inDirectory: config.sshPath)
        let gitconfigFiles = IdentityFile.files(inDirectory: config.gitconfigPath)

        let sshNames = Set(sshFiles.map { $0.identity })
        let gitconfigNames = Set(gitconfigFiles.map { $0.identity })

        let names = sshNames.intersection(gitconfigNames).subtracting([CurrentIdentity.identifier])
        return names.compactMap { try? Identity.read(name: $0, config: config) }.sorted(by: { $0.name < $1.name })
    }
}

extension Identity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Identity(name: \(name), privateKeyFile: \(privateKeyFile.debugDescription), publicKeyFile: \(publicKeyFile.debugDescription), gitconfigFile: \(gitconfigFile.debugDescription))"
    }
}

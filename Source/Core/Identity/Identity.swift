//
//  Identity.swift
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
        let fileIdentities = Set(files.map { $0.identityName })
        guard fileIdentities.count == 1, let name = fileIdentities.first else {
            throw GitIdentityError.inconsistentIdentities(files: files, identities: Array(fileIdentities).sorted())
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
            throw GitIdentityError.invalidIdentity(name: name,
                                                   symlinks: files.filter { $0.isSymlink },
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

        let sshNames = Set(sshFiles.map { $0.identityName })
        let gitconfigNames = Set(gitconfigFiles.map { $0.identityName })

        let names = sshNames.intersection(gitconfigNames).subtracting([CurrentIdentity.identifier])
        return names.compactMap { try? Identity.read(name: $0, config: config) }.sorted(by: { $0.name < $1.name })
    }
}

extension Identity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Identity(name: \(name), privateKeyFile: \(privateKeyFile.debugDescription), publicKeyFile: \(publicKeyFile.debugDescription), gitconfigFile: \(gitconfigFile.debugDescription))"
    }
}

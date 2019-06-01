//
//  CurrentIdentity.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public struct CurrentIdentity {

    public static let identifier = "current"

    public let name = CurrentIdentity.identifier

    let symlinks: Identity

    public let target: Identity

    public init(config: Configuration) throws {
        let symlinks = try Identity.read(name: CurrentIdentity.identifier, config: config)
        guard try symlinks.filesAreAllSymlinks() else {
            throw GitIdentityError.currentIdentityContainsNonSymlinks
        }

        let target = try Identity(privateKeyFile: try symlinks.privateKeyFile.resolveSymlink(),
                                  publicKeyFile: try symlinks.publicKeyFile.resolveSymlink(),
                                  gitconfigFile: try symlinks.gitconfigFile.resolveSymlink())
        self.init(symlinks: symlinks, target: target)
    }

    private init(symlinks: Identity, target: Identity) {
        self.symlinks = symlinks
        self.target = target
    }

    public var targetName: String {
        return target.name
    }
}

extension CurrentIdentity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "CurrentIdentity(name: \(name), targetName: \(targetName), symlinks: \(symlinks.debugDescription), target: \(target.debugDescription))"
    }
}

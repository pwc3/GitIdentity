//
//  CurrentIdentity.swift
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

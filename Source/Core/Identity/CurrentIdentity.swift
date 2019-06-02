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

public class CurrentIdentity {

    public static let identifier = "current"

    public let name = CurrentIdentity.identifier

    let symlinks: Identity

    public private(set) var destination: Identity

    public convenience init(config: Configuration) throws {
        let symlinks = try Identity.read(name: CurrentIdentity.identifier, config: config)
        guard try symlinks.filesAreAllSymlinks() else {
            throw GitIdentityError.currentIdentityContainsNonSymlinks
        }

        let destination = try Identity(privateKeyFile: try symlinks.privateKeyFile.resolveSymlink(),
                                       publicKeyFile: try symlinks.publicKeyFile.resolveSymlink(),
                                       gitconfigFile: try symlinks.gitconfigFile.resolveSymlink())
        if try destination.filesAreAllSymlinks() {
            throw GitIdentityError.identityContainsSymlinks(name: destination.name)
        }

        self.init(symlinks: symlinks, destination: destination)
    }

    private init(symlinks: Identity, destination: Identity) {
        self.symlinks = symlinks
        self.destination = destination
    }

    public func change(to newIdentity: Identity) throws {
        if try newIdentity.filesAreAllSymlinks() {
            throw GitIdentityError.identityContainsSymlinks(name: newIdentity.name)
        }

        let fm = FileManager.default

        try fm.removeItem(atPath: symlinks.gitconfigFile.path)
        try fm.removeItem(atPath: symlinks.publicKeyFile.path)
        try fm.removeItem(atPath: symlinks.privateKeyFile.path)

        try fm.createSymbolicLink(atPath: symlinks.gitconfigFile.path,
                                  withDestinationPath: newIdentity.gitconfigFile.path)
        try fm.createSymbolicLink(atPath: symlinks.publicKeyFile.path,
                                  withDestinationPath: newIdentity.publicKeyFile.path)
        try fm.createSymbolicLink(atPath: symlinks.privateKeyFile.path,
                                  withDestinationPath: newIdentity.privateKeyFile.path)

        destination = newIdentity
    }
}

extension CurrentIdentity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "CurrentIdentity(name: \(name), destination.name: \(destination.name), symlinks: \(symlinks.debugDescription), destination: \(destination.debugDescription))"
    }
}

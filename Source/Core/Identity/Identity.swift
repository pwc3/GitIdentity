//
//  Identity.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/4/19.
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

/// Represents an identity, comprised of paths to the associated configuration files.
public struct Identity: Codable, Equatable {

    /// The gitconfig file fragment.
    public var gitconfig: File

    /// The SSH private key file.
    public var privateKey: File

    /// The SSH public key file.
    public var publicKey: File

    /**
     Creates a new identity with the specified files.

     - Parameter gitconfig: The gitconfig file fragment.
     - Parameter privateKey: The SSH private key file.
     - Parameter publicKey: The SSH public key file.
     */
    public init(gitconfig: File, privateKey: File, publicKey: File) {
        self.gitconfig = gitconfig
        self.privateKey = privateKey
        self.publicKey = publicKey
    }

    /**
     If all of the files in this identity are symbolic links, returns another identity with the destinations of the symbolic links. If any of the files are not symbolic links or cannot be resolved, an error is thrown.

     - Throws: An error if `File.resolveSymbolicLink()` throws an error.
     - Returns: A new `Identity` with the destinations of the symbolic links in this identity.
     */
    public func resolveSymbolicLinks() throws -> Identity {
        return Identity(gitconfig: try gitconfig.resolveSymbolicLink(),
                        privateKey: try privateKey.resolveSymbolicLink(),
                        publicKey: try publicKey.resolveSymbolicLink())
    }

    /**
     Overwrites the files in this identity to be symbolic links. The destinations of these symbolic links are the files in the specified identity.

     - Throws: An error if `File.createSymbolicLink(to:)` throws an error. If an error is thrown, the files in this identity will be left in an inconsistent state.
     */
    public func createSymbolicLinks(to identity: Identity) throws {
        try gitconfig.createSymbolicLink(to: identity.gitconfig)
        try privateKey.createSymbolicLink(to: identity.privateKey)
        try publicKey.createSymbolicLink(to: identity.publicKey)
    }
}

extension Identity: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "Identity(gitconfig: \(gitconfig.path), privateKey: \(privateKey.path), publicKey: \(publicKey.path))"
    }
}

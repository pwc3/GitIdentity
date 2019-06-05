//
//  Configuration.swift
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

public struct Configuration {

    private var currentIdentitySymlinks: Identity

    private var identities: [String: Identity]

    public static func load(file: File = File(path: "~/.git-identity-config.json")) throws -> Configuration {
        return try load(url: file.url)
    }

    public static func load(url: URL) throws -> Configuration {
        return try load(data: try Data(contentsOf: url))
    }

    public static func load(data: Data) throws -> Configuration {
        return try JSONDecoder().decode(Configuration.self, from: data)
    }

    public var identityNames: [String] {
        return identities.keys.sorted()
    }

    public func name(for identity: Identity) -> String? {
        for (name, id) in identities {
            if id == identity {
                return name
            }
        }
        return nil
    }

    public func identity(forName name: String) -> Identity? {
        return identities[name]
    }

    public func loadCurrentIdentity() throws -> CurrentIdentity {
        let destination = try currentIdentitySymlinks.resolveSymlinks()
        guard let name = name(for: destination) else {
            throw GitIdentityError.currentIdentityNameNotFound
        }

        return CurrentIdentity(name: name, destination: destination)
    }

    public func setCurrentIdentity(name: String) throws {
        guard let identity = identity(forName: name) else {
            throw GitIdentityError.identityNotFound(name: name)
        }

        try currentIdentitySymlinks.symlink(to: identity)
    }
}

extension Configuration: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        var identities = try container.decode([String: Identity].self)
        guard let current = identities["current"] else {
            throw GitIdentityError.currentIdentitySymlinksNotDefined
        }

        identities.removeValue(forKey: "current")

        self.init(currentIdentitySymlinks: current, identities: identities)
    }

    public func encode(to encoder: Encoder) throws {
        var identities = self.identities
        identities["current"] = currentIdentitySymlinks

        var container = encoder.singleValueContainer()
        try container.encode(identities)
    }
}

extension Configuration: CustomDebugStringConvertible {

    public var debugDescription: String {
        let json = String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
        return "Configuration( \(json) )"
    }
}

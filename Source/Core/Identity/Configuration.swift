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

/// Contains the `current` identity symbolic link locations as well as the other identities defined by the user.
public struct Configuration {

    /// The `current` identity in the configuration, containing symbolic links to an actual identity.
    private var currentIdentitySymlinks: Identity

    /// A dictionary mapping from name to `Identity`.
    private var identities: [String: Identity]

    /**
     Loads the configuration from the specified file (`~/.git-identity-config.json` by default).

     - Parameter file: The configuration file path.
     - Throws: An error if the configuration file cannot be found or loaded.
     */
    public static func load(file: File = File(path: "~/.git-identity-config.json")) throws -> Configuration {
        return try load(url: file.url)
    }

    /**
     Loads the configuration from the specified URL.

     - Parameter url: The configuration file URL.
     - Throws: An error if the configuration file cannot be found or loaded.
     */
    public static func load(url: URL) throws -> Configuration {
        return try load(data: try Data(contentsOf: url))
    }

    /**
     Loads the configuration from the specified JSON object.

     - Parameter data: A data value containing a JSON string.
     - Throws: An error if the configuration file cannot be found or loaded.
     */
    public static func load(data: Data) throws -> Configuration {
        return try JSONDecoder().decode(Configuration.self, from: data)
    }

    /// An array containing the identity names defined in this configuration. The array is sorted alphabetically.
    public var identityNames: [String] {
        return identities.keys.sorted()
    }

    /**
     Returns the name for the identity in this configuration that matches the specified identity, or `nil` if one could be found.

     - Parameter identity: The identity whose name is being retrieved.
     - Returns: The name of the specified identity, or `nil` if no matching identities could be found.
     */
    public func name(for identity: Identity) -> String? {
        for (name, id) in identities where id == identity {
            return name
        }
        return nil
    }

    /**
     Returns the identity for the specified name, or `nil` if one could not be found.

     - Parameter name: The name of the identity to be retrieved.
     - Returns: The identity defined under the specified name in this configuration, or `nil` if no matching names could be found.
     */
    public func identity(forName name: String) -> Identity? {
        return identities[name]
    }

    /**
     Loads the current identity. Resolves the symbolic links in the `current` identity and looks up the corresponding name. These values are used to construct a new `CurrentIdentity` object.

     - Throws: An error if the `current` identity's symbolic links could not be resolved.
     - Throws: An error if no name could be found in the configuration matching the target of the `current` identity's symbolic links.
     - Returns: The current identity.
     */
    public func loadCurrentIdentity() throws -> CurrentIdentity {
        let destination = try currentIdentitySymlinks.resolveSymbolicLinks()
        guard let name = name(for: destination) else {
            throw GitIdentityError.currentIdentityNameNotFound
        }

        return CurrentIdentity(name: name, destination: destination)
    }

    /**
     Sets the current identity. Changes the symbolic links in the `current` identity to point to the files associated with the specified identity.

     - Throws: An error if an identity cannot be found for the specified name.
     - Throws: An error if the symbolic links are unable to be created.
     */
    public func setCurrentIdentity(name: String) throws {
        guard let identity = identity(forName: name) else {
            throw GitIdentityError.identityNotFound(name: name)
        }

        try currentIdentitySymlinks.createSymbolicLinks(to: identity)
        IdentityChangedNotification.post(currentIdentity: name)
    }
}

extension Configuration: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        var identities = try container.decode([String: Identity].self)
        guard let current = identities["current"] else {
            throw GitIdentityError.currentIdentityNotDefined
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
        // swiftlint:disable:next force_try force_unwrapping
        let json = String(data: try! JSONEncoder().encode(self), encoding: .utf8)!
        return "Configuration( \(json) )"
    }
}

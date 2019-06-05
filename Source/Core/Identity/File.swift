//
//  File.swift
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

/// Represents a file path.
public struct File: Equatable {

    /// The path of this file. The initializer automatically expands any tilde in the path (via `NSString.expandingTildeInPath`).
    public var path: String

    /**
     Creates a new `File` value with the specified path. The created object's path will have any tilde expanded (via `NSString.expandingTildeInPath`).

     - Parameter path: The path of the file.
     */
    public init(path: String) {
        self.path = (path as NSString).expandingTildeInPath
    }

    /// A file URL with this file's path.
    public var url: URL {
        return URL(fileURLWithPath: path)
    }

    /// Indicates whether a file exists at this path.
    public var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    /// Indicates whether a file exists at this path and is a symbolic link. If an error is raised by the underlying `FileManager` call, `false` will be returned.
    public var isSymbolicLink: Bool {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path)
            guard let type = attrs[.type] as? FileAttributeType, type == .typeSymbolicLink else {
                return false
            }
            return true
        }
        catch {
            return false
        }
    }

    /**
     Returns a new `File` value representing the destination of the symbolic link.

     - Throws: An error if this is not a symbolic link.
     - Throws: An error if the symbolic link cannot be resolved.
     - Returns: A new `File` value representing the destination of the symbolic link.
     */
    public func resolveSymbolicLink() throws -> File {
        guard isSymbolicLink else {
            throw GitIdentityError.fileIsNotSymbolicLink(atPath: path)
        }

        return File(path: try FileManager.default.destinationOfSymbolicLink(atPath: path))
    }

    /**
     Reads the contents of this file as a string.

     - Throws: An error if the file cannot be read as a string.
     - Returns: The contents of this file as a string.
     */
    public func readString() throws -> String {
        return try String(contentsOfFile: path)
    }

    /**
     Creates a symbolic link with the specified destination. If this file exists, it is first removed.

     - Throws: An error if this file exists but cannot be removed.
     - Throws: An error if the symbolic link cannot be created.
     - Parameter destination: The destination of the symbolic link.
     */
    public func createSymbolicLink(to destination: File) throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
        try FileManager.default.createSymbolicLink(atPath: path, withDestinationPath: destination.path)
    }
}

extension File: Codable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(path: try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(path)
    }
}

extension File: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "File(path: \(path))"
    }
}

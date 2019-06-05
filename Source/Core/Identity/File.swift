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

public struct File: Equatable {

    public var path: String

    public init(path: String) {
        self.path = (path as NSString).expandingTildeInPath
    }

    public var url: URL {
        return URL(fileURLWithPath: path)
    }

    public var exists: Bool {
        return FileManager.default.fileExists(atPath: path)
    }

    public var isSymlink: Bool {
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

    public func resolveSymlink() throws -> File {
        guard isSymlink else {
            throw GitIdentityError.fileIsNotSymlink(atPath: path)
        }

        return File(path: try FileManager.default.destinationOfSymbolicLink(atPath: path))
    }

    public func readString() throws -> String {
        return try String(contentsOfFile: path)
    }

    public func delete() throws {
        try FileManager.default.removeItem(atPath: path)
    }

    public func createSymlink(to destination: File) throws {
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

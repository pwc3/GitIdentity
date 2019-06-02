//
//  IdentityFile.swift
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

public class IdentityFile {

    public let path: String

    public let type: IdentityFileType

    public let identity: String

    required init(path: String, type: IdentityFileType, identity: String) throws {
        guard FileManager.default.fileExists(atPath: path) else {
            throw GitIdentityError.fileNotFound(atPath: path)
        }

        self.path = (path as NSString).expandingTildeInPath
        self.type = type
        self.identity = identity
    }

    convenience init(path: String) throws {
        let filename = (path as NSString).lastPathComponent
        guard let type = IdentityFileType.all.first(where: { $0.matches(filename: filename) }) else {
            throw GitIdentityError.cannotDetermineIdentityFromFile(atPath: path)
        }
        try self.init(path: path, type: type)
    }

    convenience init(path: String, type: IdentityFileType) throws {
        guard let identity = type.identity(forFilename: (path as NSString).lastPathComponent) else {
            throw GitIdentityError.cannotDetermineIdentityFromFile(atPath: path)
        }

        try self.init(path: (path as NSString).expandingTildeInPath,
                      type: type,
                      identity: identity)
    }

    convenience init(type: IdentityFileType, inDirectory directory: String, forIdentity identity: String) throws {
        try self.init(path: (directory as NSString).appendingPathComponent(type.filename(forIdentity: identity)),
                      type: type,
                      identity: identity)
    }

    static func files(inDirectories directories: [String]) -> [IdentityFile] {
        return directories.map { files(inDirectory: $0) }.flatMap { $0 }.sorted(by: { $0.path < $1.path })
    }

    static func files(inDirectory directory: String) -> [IdentityFile] {
        let filenames = (try? FileManager.default.contentsOfDirectory(atPath: directory)) ?? []
        let dir: NSString = directory as NSString

        return files(inDirectoryContents: filenames.map { dir.appendingPathComponent($0) }).sorted(by: { $0.path < $1.path })
    }

    static func files(inDirectoryContents contents: [String]) -> [IdentityFile] {
        return contents.compactMap { try? IdentityFile(path: $0) }
    }

    var isSymlink: Bool {
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

    func resolveSymlink() throws -> IdentityFile {
        guard isSymlink else {
            throw GitIdentityError.fileIsNotSymlink(atPath: path)
        }
        let dest = try FileManager.default.destinationOfSymbolicLink(atPath: path)
        let file = try IdentityFile(path: dest)

        guard file.type === self.type else {
            throw GitIdentityError.symlinkTypeMismatch(symlinkType: type, destinationType: file.type)
        }

        return file
    }

    func readContents() throws -> String {
        return try String(contentsOfFile: path)
    }
}

extension IdentityFile: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "IdentityFile(path: \((path as NSString).abbreviatingWithTildeInPath), type: \(type), identity: \(identity), isSymlink: \(isSymlink))"
    }
}

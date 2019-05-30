//
//  IdentityFile.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

enum IdentityFileError: Error {

    case couldNotParseFilename(String)

    case fileNotFound(String)

    case fileNotSymlink(String)
}

public class IdentityFile {

    public class FileType {

        public static let privateKey = FileType(formatString: "id_rsa_git_%@", pattern: #"id_rsa_git_([^\.]+)$"#)

        public static let publicKey = FileType(formatString: "id_rsa_git_%@.pub", pattern: #"id_rsa_git_([^\.]+)\.pub$"#)

        public static let gitconfig = FileType(formatString: ".gitconfig_identity_%@", pattern: #".gitconfig_identity_([^\.]+)$"#)

        public static let all: [FileType] = [
            .privateKey, .publicKey, .gitconfig
        ]

        private let formatString: String

        private let regex: NSRegularExpression

        private init(formatString: String, pattern: String) {
            self.formatString = formatString
            self.regex = try! NSRegularExpression(pattern: pattern)
        }

        func filename(forIdentity identity: String) -> String {
            return String(format: formatString, identity)
        }

        func identity(forFilename filename: String) throws -> String {
            let range = NSRange(filename.startIndex..<filename.endIndex, in: filename)
            guard
                let match = regex.firstMatch(in: filename, options: [], range: range),
                match.numberOfRanges == 2
            else {
                throw IdentityFileError.couldNotParseFilename(filename)
            }

            let nsRange = match.range(at: 1)
            guard
                nsRange.location != NSNotFound,
                let identityRange = Range(nsRange, in: filename)
            else {
                throw IdentityFileError.couldNotParseFilename(filename)
            }

            return String(filename[identityRange])
        }

        func matches(filename: String) -> Bool {
            return (try? identity(forFilename: filename)) != nil
        }
    }

    public let path: String

    public let type: FileType

    public let identity: String

    required init(path: String, type: FileType, identity: String) {
        self.path = (path as NSString).expandingTildeInPath
        self.type = type
        self.identity = identity
    }

    convenience init?(path: String) {
        let filename = (path as NSString).lastPathComponent
        guard let type = FileType.all.first(where: { $0.matches(filename: filename) }) else {
            return nil
        }
        try? self.init(path: path, type: type)
    }

    convenience init(path: String, type: FileType) throws {
        self.init(path: (path as NSString).expandingTildeInPath,
                  type: type,
                  identity: try type.identity(forFilename: (path as NSString).lastPathComponent))
    }

    convenience init(type: FileType, inDirectory directory: String, forIdentity identity: String) {
        self.init(path: (directory as NSString).appendingPathComponent(type.filename(forIdentity: identity)),
                  type: type,
                  identity: identity)
    }

    static func files(inDirectory directory: String) throws -> [IdentityFile] {
        return files(inDirecoryContents: try FileManager.default.contentsOfDirectory(atPath: directory))
    }

    static func files(inDirecoryContents contents: [String]) -> [IdentityFile] {
        return contents.compactMap { IdentityFile(path: $0) }
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
}

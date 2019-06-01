//
//  IdentityFileType.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/31/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class IdentityFileType: CustomStringConvertible, Equatable {

    public static let privateKey = IdentityFileType("privateKey", formatString: "id_rsa_git_%@", pattern: #"id_rsa_git_([^\.]+)$"#)

    public static let publicKey = IdentityFileType("publicKey", formatString: "id_rsa_git_%@.pub", pattern: #"id_rsa_git_([^\.]+)\.pub$"#)

    public static let gitconfig = IdentityFileType("gitconfig", formatString: ".gitconfig_identity_%@", pattern: #".gitconfig_identity_([^\.]+)$"#)

    public static let all: [IdentityFileType] = [
        .privateKey, .publicKey, .gitconfig
    ]

    public let description: String

    private let formatString: String

    private let regex: NSRegularExpression

    private init(_ description: String, formatString: String, pattern: String) {
        self.description = description
        self.formatString = formatString
        self.regex = try! NSRegularExpression(pattern: pattern)
    }

    func filename(forIdentity identity: String) -> String {
        return String(format: formatString, identity)
    }

    func identity(forFilename filename: String) -> String? {
        let range = NSRange(filename.startIndex..<filename.endIndex, in: filename)
        guard
            let match = regex.firstMatch(in: filename, options: [], range: range),
            match.numberOfRanges == 2
        else {
            return nil
        }

        let nsRange = match.range(at: 1)
        guard
            nsRange.location != NSNotFound,
            let identityRange = Range(nsRange, in: filename)
        else {
            return nil
        }

        return String(filename[identityRange])
    }

    func matches(filename: String) -> Bool {
        return identity(forFilename: filename) != nil
    }

    public static func == (lhs: IdentityFileType, rhs: IdentityFileType) -> Bool {
        return lhs.description == rhs.description
    }
}

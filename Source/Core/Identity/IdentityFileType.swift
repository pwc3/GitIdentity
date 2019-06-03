//
//  IdentityFileType.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/31/19.
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

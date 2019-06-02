//
//  GitIdentityError.swift
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

public enum GitIdentityError: Error {

    case incorrectNumberOfArguments

    case unrecognizedCommand(String)

    case fileNotFound(atPath: String)

    case fileIsNotSymlink(atPath: String)

    case cannotDetermineIdentityFromFile(atPath: String)

    // TODO: Add symlink and destination to error
    case symlinkTypeMismatch(symlinkType: IdentityFileType, destinationType: IdentityFileType)

    // TODO: Rename and add information for error message
    case inconsistentIdentities(files: [IdentityFile])

    // TODO: Add identity name
    case invalidIdentity(symlinks: [IdentityFile], notSymlinks: [IdentityFile])

    case currentIdentityContainsNonSymlinks

    // TODO: Add identity name
    case identityContainsSymlinks
}

extension GitIdentityError: LocalizedError {

    private func paths(for files: [IdentityFile]) -> String {
        return files.map { $0.path }.joined(separator: ", ")
    }

    public var errorDescription: String? {
        switch self {
        case .incorrectNumberOfArguments:
            return "Incorrect number of arguments"

        case .unrecognizedCommand(let command):
            return "Unrecognized command: \"\(command)\""

        case .fileNotFound(let path):
            return "File not found at \(path)"

        case .fileIsNotSymlink(let path):
            return "Expected symlink at \(path)"

        case .cannotDetermineIdentityFromFile(let path):
            return "Cannot determine identity from file at \(path)"

        case .symlinkTypeMismatch(let symlinkType, let destinationType):
            return "Symlink is \(symlinkType.description), destination is \(destinationType.description)"

        case .inconsistentIdentities(let files):
            return "Inconsistent identities in files: \(paths(for: files))"

        case .invalidIdentity(let symlinks, let notSymlinks):
            return "Invalid identity with mixed symlinks (\(paths(for: symlinks))) and files (\(paths(for: notSymlinks)))"

        case .currentIdentityContainsNonSymlinks:
            return "The \"current\" identity must be comprised solely of symlinks."

        case .identityContainsSymlinks:
            return "The specified identity must not be comprised of any symlinks."
        }
    }
}

//
//  GitIdentityError.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/31/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public enum GitIdentityError: Error {

    case compoundError([Error])

    case incorrectNumberOfArguments

    case unrecognizedCommand(String)

    case fileNotFound(atPath: String)

    case fileIsNotSymlink(atPath: String)

    case unrecognizedFileType(atPath: String)

    case cannotDetermineIdentityFromFile(atPath: String)

    case symlinkTypeMismatch(sourceType: IdentityFileType, targetType: IdentityFileType)

    case inconsistentIdentities(files: [IdentityFile])

    case invalidIdentity(symlinks: [IdentityFile], notSymlinks: [IdentityFile])

    case currentIdentityContainsNonSymlinks
}

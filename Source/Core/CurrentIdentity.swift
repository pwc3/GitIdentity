//
//  CurrentIdentity.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

/*
 Need two paths here. One to read and one to write.
 */
public struct CurrentIdentity {

    public static let identifier = "current"

    let privateKeySymlink: IdentityFile

    let privateKeyFile: IdentityFile

    let publicKeySymlink: IdentityFile

    let publicKeyFile: IdentityFile

    let gitconfigSymlink: IdentityFile

    let gitconfigFile: IdentityFile

    public let name = CurrentIdentity.identifier

//    public init(config: Configuration) {
//        let identity = Identity(name: CurrentIdentity.identifier, config: config)
//
//        self.privateKeySymlink = identity.privateKeyFile
//        self.publicKeySymlink = identity.publicKeyFile
//        self.gitconfigSymlink = identity.publicKeyFile
//    }
//
//    public static func read(config: Configuration) throws -> CurrentIdentity {
//        func resolve(_ file: IdentityFile) throws -> (symlink: IdentityFile, target: IdentityFile) {
//
//        }
//
//        let privateKeySymlink = identity.privateKeyFile
//    }
//
//    public func validate() throws {
//        let badFiles = [privateKeySymlink, publicKeySymlink, gitconfigSymlink].filter {
//            $0.exists && !$0.isSymlink
//        }
//        guard badFiles.isEmpty else {
//            throw ValidationError.existingFilesAreNotSymlinks(badFiles)
//        }
//    }
//
//    var privateKeyFile: IdentityFile? {
//        get {
//            return privateKeySymlink.resolveSymlink()
//        }
//    }
//
//    var publicKeyFile: IdentityFile? {
//        get {
//            return publicKeySymlink.resolveSymlink()
//        }
//    }
//
//    var gitconfigFile: IdentityFile? {
//        get {
//            return gitconfigSymlink.resolveSymlink()
//        }
//    }
//
//    var files: [IdentityFile] {
//        return [privateKeyFile, publicKeyFile, gitconfigFile].compactMap { $0 }
//    }
//    public var identity: String? {
//        let names = Set(files.map { $0.identity })
//        if names.count == 1 {
//            return names.first
//        }
//        else {
//            return nil
//        }
//    }
}

extension CurrentIdentity: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "CurrentIdentity(privateKeySymlink: \(privateKeySymlink.debugDescription), privateKeyFile: \(privateKeyFile.debugDescription), publicKeySymlink: \(publicKeySymlink.debugDescription), publicKeyFile: \(publicKeyFile.debugDescription), gitconfigSymlink: \(gitconfigSymlink.debugDescription), gitconfigFile: \(gitconfigFile.debugDescription))"
    }
}

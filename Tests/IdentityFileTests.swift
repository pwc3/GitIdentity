//
//  IdentityFileTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

@testable import GitIdentityCore
import XCTest

class IdentityFileTests: XCTestCase {

    private static var fs: Sandbox!

    override class func setUp() {
        super.setUp()
        fs = try! Sandbox()

        try! fs.create(".bashrc")
        try! fs.create(".bash_history")
        try! fs.create(".gitconfig_identity_personal")
        try! fs.create(".gitconfig_identity_work")
        try! fs.create(".ssh/config")
        try! fs.create(".ssh/id_rsa_git_personal")
        try! fs.create(".ssh/id_rsa_git_personal.pub")
        try! fs.create(".ssh/id_rsa_git_work")
        try! fs.create(".ssh/id_rsa_git_work.pub")
        try! fs.create(".ssh/known_hosts")
    }

    override class func tearDown() {
        try! fs.destroy()
    }

    private var fs: Sandbox! {
        return IdentityFileTests.fs
    }

    private var rootPath: String {
        return fs.root.path
    }

    private var sshPath: String {
        return fs.path(".ssh")
    }

    func testParsePathGitConfig() throws {
        let f = try IdentityFile(path: fs.path(".gitconfig_identity_personal"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertTrue(f.type == .gitconfig)
    }

    func testGitConfigPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".gitconfig_identity_personal"), type: .publicKey))
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".gitconfig_identity_personal"), type: .privateKey))

        let f = try IdentityFile(path: fs.path(".gitconfig_identity_personal"), type: .gitconfig)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .gitconfig)
    }

    func testGitConfig() throws {
        let f = try IdentityFile(type: .gitconfig, inDirectory: rootPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, fs.path(".gitconfig_identity_personal"))
        XCTAssertEqual(f.type, .gitconfig)
    }

    func testParsePathPrivateKey() throws {
        let f = try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .privateKey)
    }

    func testPrivateKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal"), type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal"), type: .publicKey))

        let f = try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal"), type: .privateKey)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .privateKey)
    }

    func testPrivateKey() throws {
        let f = try IdentityFile(type: .privateKey, inDirectory: sshPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, fs.path(".ssh/id_rsa_git_personal"))
        XCTAssertEqual(f.type, .privateKey)
    }

    func testParsePathPublicKey() throws {
        let f = try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal.pub"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .publicKey)
    }

    func testPublicKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal.pub"), type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal.pub"), type: .privateKey))

        let f = try IdentityFile(path: fs.path(".ssh/id_rsa_git_personal.pub"), type: .publicKey)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .publicKey)
    }

    func testPublicKey() throws {
        let f = try IdentityFile(type: .publicKey, inDirectory: sshPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, fs.path(".ssh/id_rsa_git_personal.pub"))
        XCTAssertEqual(f.type, .publicKey)
    }

    func testUnrecognizedFilename() throws {
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/Dropbox"))
    }

    func testFindFiles() {
        let matches = IdentityFile.files(inDirectories: [rootPath, sshPath])
        XCTAssertEqual(matches.count, 6)

        guard matches.count == 6 else {
            XCTFail("Incorrect number of matches -- skipping remainder of test")
            return
        }

        XCTAssertEqual(matches[0].identity, "personal")
        XCTAssertEqual(matches[0].type, .gitconfig)
        XCTAssertEqual(matches[0].path, fs.path(".gitconfig_identity_personal"))

        XCTAssertEqual(matches[1].identity, "work")
        XCTAssertEqual(matches[1].type, .gitconfig)
        XCTAssertEqual(matches[1].path, fs.path(".gitconfig_identity_work"))

        XCTAssertEqual(matches[2].identity, "work")
        XCTAssertEqual(matches[2].type, .privateKey)
        XCTAssertEqual(matches[2].path, fs.path(".ssh/id_rsa_git_work"))

        XCTAssertEqual(matches[3].identity, "personal")
        XCTAssertEqual(matches[3].type, .privateKey)
        XCTAssertEqual(matches[3].path, fs.path(".ssh/id_rsa_git_personal"))

        XCTAssertEqual(matches[4].identity, "personal")
        XCTAssertEqual(matches[4].type, .publicKey)
        XCTAssertEqual(matches[4].path, fs.path(".ssh/id_rsa_git_personal.pub"))

        XCTAssertEqual(matches[5].identity, "work")
        XCTAssertEqual(matches[5].type, .publicKey)
        XCTAssertEqual(matches[5].path, fs.path(".ssh/id_rsa_git_work.pub"))
    }
}

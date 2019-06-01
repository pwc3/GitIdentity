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

        try! fs.createSymlink(at: ".gitconfig_identity_current", destination: ".gitconfig_identity_personal")
        try! fs.createSymlink(at: ".ssh/id_rsa_git_current", destination: ".ssh/id_rsa_git_personal")
        try! fs.createSymlink(at: ".ssh/id_rsa_git_current.pub", destination: ".ssh/id_rsa_git_personal.pub")
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

    func verify(_ identityFile: IdentityFile, _ identity: String, _ type: IdentityFileType, _ path: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(identityFile.identity, identity, file: file, line: line)
        XCTAssertEqual(identityFile.type, type, file: file, line: line)
        XCTAssertEqual(identityFile.path, fs.path(path), file: file, line: line)
    }

    func testFindFiles() {
        let matches = IdentityFile.files(inDirectories: [rootPath, sshPath])
        XCTAssertEqual(matches.count, 9)

        guard matches.count == 9 else {
            XCTFail("Incorrect number of matches -- skipping remainder of test")
            return
        }

        print(matches)

        verify(matches[0], "current", .gitconfig, ".gitconfig_identity_current")
        verify(matches[1], "personal", .gitconfig, ".gitconfig_identity_personal")
        verify(matches[2], "work", .gitconfig, ".gitconfig_identity_work")

        verify(matches[3], "current", .privateKey, ".ssh/id_rsa_git_current")
        verify(matches[4], "current", .publicKey, ".ssh/id_rsa_git_current.pub")

        verify(matches[5], "personal", .privateKey, ".ssh/id_rsa_git_personal")
        verify(matches[6], "personal", .publicKey, ".ssh/id_rsa_git_personal.pub")

        verify(matches[7], "work", .privateKey, ".ssh/id_rsa_git_work")
        verify(matches[8], "work", .publicKey, ".ssh/id_rsa_git_work.pub")
    }

    func testSymlink() throws {
        let gitconfigSymlink = try IdentityFile(path: fs.path(".gitconfig_identity_current"), type: .gitconfig, identity: "current")
        XCTAssertTrue(gitconfigSymlink.isSymlink)
        verify(gitconfigSymlink, "current", .gitconfig, ".gitconfig_identity_current")

        let gitconfigPersonal = try IdentityFile(path: fs.path(".gitconfig_identity_personal"), type: .gitconfig, identity: "personal")
        XCTAssertFalse(gitconfigPersonal.isSymlink)
        verify(gitconfigPersonal, "personal", .gitconfig, ".gitconfig_identity_personal")

        XCTAssertThrowsError(try gitconfigPersonal.resolveSymlink())

        let gitconfigSymlinkTarget = try gitconfigSymlink.resolveSymlink()
        XCTAssertFalse(gitconfigSymlinkTarget.isSymlink)
        verify(gitconfigSymlinkTarget, "personal", .gitconfig, ".gitconfig_identity_personal")

        XCTAssertEqual(gitconfigPersonal.path, gitconfigSymlinkTarget.path)
    }

    func testSymlinkTypeMismatch() throws {
        let fs = try Sandbox()
        defer {
            try! fs.destroy()
        }

        try fs.create(".ssh/id_rsa_git_personal")
        try fs.createSymlink(at: ".gitconfig_identity_personal", destination: ".ssh/id_rsa_git_personal")

        let symlink = try IdentityFile(path: fs.path(".gitconfig_identity_personal"))
        XCTAssertTrue(symlink.isSymlink)
        XCTAssertThrowsError(try symlink.resolveSymlink())
    }

    func testFileNotFound() {
        XCTAssertThrowsError(try IdentityFile(path: fs.path("this_file_does_not_exist")))
    }
}

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

    func testParsePathGitConfig() {
        guard let f = IdentityFile(path: "/Users/me/.gitconfig_identity_fnord") else {
            XCTFail("Could not parse path")
            return
        }
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.gitconfig)
    }

    func testGitConfigPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.gitconfig_identity_fnord", type: .publicKey))
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.gitconfig_identity_fnord", type: .privateKey))

        let f = try IdentityFile(path: "/Users/me/.gitconfig_identity_fnord", type: .gitconfig)
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.gitconfig)
    }

    func testGitConfig() {
        let f = IdentityFile(type: .gitconfig, inDirectory: "/Users/me/foobar", forIdentity: "fnord")
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertEqual(f.path, "/Users/me/foobar/.gitconfig_identity_fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.gitconfig)
    }

    func testParsePathPrivateKey() {
        guard let f = IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord") else {
            XCTFail("Could not parse path")
            return
        }
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.privateKey)
    }

    func testPrivateKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord", type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord", type: .publicKey))

        let f = try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord", type: .privateKey)
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.privateKey)
    }

    func testPrivateKey() {
        let f = IdentityFile(type: .privateKey, inDirectory: "/Users/me/foobar", forIdentity: "fnord")
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertEqual(f.path, "/Users/me/foobar/id_rsa_git_fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.privateKey)
    }

    func testParsePathPublicKey() {
        guard let f = IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord.pub") else {
            XCTFail("Could not parse path")
            return
        }
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.publicKey)
    }

    func testPublicKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord.pub", type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord.pub", type: .privateKey))

        let f = try IdentityFile(path: "/Users/me/.ssh/id_rsa_git_fnord.pub", type: .publicKey)
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertTrue(f.type === IdentityFile.FileType.publicKey)
    }

    func testPublicKey() {
        let f = IdentityFile(type: .publicKey, inDirectory: "/Users/me/foobar", forIdentity: "fnord")
        XCTAssertEqual(f.identity, "fnord")
        XCTAssertEqual(f.path, "/Users/me/foobar/id_rsa_git_fnord.pub")
        XCTAssertTrue(f.type === IdentityFile.FileType.publicKey)
    }

    func testUnrecognizedFilename() {
        XCTAssertNil(IdentityFile(path: "/Users/me/Dropbox"))
    }

    func testFindFiles() {
        let files = [
            "/Users/me/.bashrc",
            "/Users/me/.bash_history",
            "/Users/me/.gitconfig_identity_work",
            "/Users/me/.ssh/config",
            "/Users/me/.ssh/known_hosts",
            "/Users/me/.ssh/id_rsa_git_work",
            "/Users/me/.ssh/id_rsa_git_work.pub",
            "/Users/me/.gitconfig_identity_personal",
            "/Users/me/.ssh/id_rsa_git_personal",
            "/Users/me/.ssh/id_rsa_git_personal.pub",
        ]

        let matches = IdentityFile.files(inDirecoryContents: files)
        XCTAssertEqual(matches.count, 6)

        XCTAssertEqual(matches[0].identity, "work")
        XCTAssertTrue(matches[0].type === IdentityFile.FileType.gitconfig)
        XCTAssertEqual(matches[0].path, "/Users/me/.gitconfig_identity_work")

        XCTAssertEqual(matches[1].identity, "work")
        XCTAssertTrue(matches[1].type === IdentityFile.FileType.privateKey)
        XCTAssertEqual(matches[1].path, "/Users/me/.ssh/id_rsa_git_work")

        XCTAssertEqual(matches[2].identity, "work")
        XCTAssertTrue(matches[2].type === IdentityFile.FileType.publicKey)
        XCTAssertEqual(matches[2].path, "/Users/me/.ssh/id_rsa_git_work.pub")

        XCTAssertEqual(matches[3].identity, "personal")
        XCTAssertTrue(matches[3].type === IdentityFile.FileType.gitconfig)
        XCTAssertEqual(matches[3].path, "/Users/me/.gitconfig_identity_personal")

        XCTAssertEqual(matches[4].identity, "personal")
        XCTAssertTrue(matches[4].type === IdentityFile.FileType.privateKey)
        XCTAssertEqual(matches[4].path, "/Users/me/.ssh/id_rsa_git_personal")

        XCTAssertEqual(matches[5].identity, "personal")
        XCTAssertTrue(matches[5].type === IdentityFile.FileType.publicKey)
        XCTAssertEqual(matches[5].path, "/Users/me/.ssh/id_rsa_git_personal.pub")
    }
}

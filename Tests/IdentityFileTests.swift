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

    private static var outputDir: URL!

    private static var outputPath: String {
        return outputDir.path
    }

    private static var sshDir: URL {
        return URL(fileURLWithPath: ".ssh", relativeTo: outputDir)
    }

    private static var sshPath: String {
        return sshDir.path
    }

    private class func create(filename: String) {
        let outputUrl = URL(fileURLWithPath: filename, relativeTo: outputDir)
        let parent = outputUrl.deletingLastPathComponent()
        try! FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        try! "".write(to: outputUrl, atomically: true, encoding: .utf8)
        print("Created \(outputUrl.path)")
    }

    override class func setUp() {
        outputDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
        try! FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        create(filename: ".bashrc")
        create(filename: ".bash_history")
        create(filename: ".gitconfig_identity_personal")
        create(filename: ".gitconfig_identity_work")
        create(filename: ".ssh/config")
        create(filename: ".ssh/id_rsa_git_personal")
        create(filename: ".ssh/id_rsa_git_personal.pub")
        create(filename: ".ssh/id_rsa_git_work")
        create(filename: ".ssh/id_rsa_git_work.pub")
        create(filename: ".ssh/known_hosts")
    }

    override class func tearDown() {
        try! FileManager.default.removeItem(at: outputDir)
    }

    private func path(_ filename: String) -> String {
        return URL(fileURLWithPath: filename, relativeTo: IdentityFileTests.outputDir).path
    }

    func testParsePathGitConfig() throws {
        let f = try IdentityFile(path: path(".gitconfig_identity_personal"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertTrue(f.type == .gitconfig)
    }

    func testGitConfigPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: path(".gitconfig_identity_personal"), type: .publicKey))
        XCTAssertThrowsError(try IdentityFile(path: path(".gitconfig_identity_personal"), type: .privateKey))

        let f = try IdentityFile(path: path(".gitconfig_identity_personal"), type: .gitconfig)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .gitconfig)
    }

    func testGitConfig() throws {
        let f = try IdentityFile(type: .gitconfig, inDirectory: IdentityFileTests.outputPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, path(".gitconfig_identity_personal"))
        XCTAssertEqual(f.type, .gitconfig)
    }

    func testParsePathPrivateKey() throws {
        let f = try IdentityFile(path: path(".ssh/id_rsa_git_personal"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .privateKey)
    }

    func testPrivateKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: path(".ssh/id_rsa_git_personal"), type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: path(".ssh/id_rsa_git_personal"), type: .publicKey))

        let f = try IdentityFile(path: path(".ssh/id_rsa_git_personal"), type: .privateKey)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .privateKey)
    }

    func testPrivateKey() throws {
        let f = try IdentityFile(type: .privateKey, inDirectory: IdentityFileTests.sshPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, path(".ssh/id_rsa_git_personal"))
        XCTAssertEqual(f.type, .privateKey)
    }

    func testParsePathPublicKey() throws {
        let f = try IdentityFile(path: path(".ssh/id_rsa_git_personal.pub"))
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .publicKey)
    }

    func testPublicKeyPath() throws {
        XCTAssertThrowsError(try IdentityFile(path: path(".ssh/id_rsa_git_personal.pub"), type: .gitconfig))
        XCTAssertThrowsError(try IdentityFile(path: path(".ssh/id_rsa_git_personal.pub"), type: .privateKey))

        let f = try IdentityFile(path: path(".ssh/id_rsa_git_personal.pub"), type: .publicKey)
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.type, .publicKey)
    }

    func testPublicKey() throws {
        let f = try IdentityFile(type: .publicKey, inDirectory: IdentityFileTests.sshPath, forIdentity: "personal")
        XCTAssertEqual(f.identity, "personal")
        XCTAssertEqual(f.path, path(".ssh/id_rsa_git_personal.pub"))
        XCTAssertEqual(f.type, .publicKey)
    }

    func testUnrecognizedFilename() throws {
        XCTAssertThrowsError(try IdentityFile(path: "/Users/me/Dropbox"))
    }

    func testFindFiles() {

        let matches = IdentityFile.files(inDirectories: [IdentityFileTests.outputPath, IdentityFileTests.sshPath])
        XCTAssertEqual(matches.count, 6)

        guard matches.count == 6 else {
            XCTFail("Incorrect number of matches -- skipping remainder of test")
            return
        }

        XCTAssertEqual(matches[0].identity, "personal")
        XCTAssertEqual(matches[0].type, .gitconfig)
        XCTAssertEqual(matches[0].path, path(".gitconfig_identity_personal"))

        XCTAssertEqual(matches[1].identity, "work")
        XCTAssertEqual(matches[1].type, .gitconfig)
        XCTAssertEqual(matches[1].path, path(".gitconfig_identity_work"))

        XCTAssertEqual(matches[2].identity, "work")
        XCTAssertEqual(matches[2].type, .privateKey)
        XCTAssertEqual(matches[2].path, path(".ssh/id_rsa_git_work"))

        XCTAssertEqual(matches[3].identity, "personal")
        XCTAssertEqual(matches[3].type, .privateKey)
        XCTAssertEqual(matches[3].path, path(".ssh/id_rsa_git_personal"))

        XCTAssertEqual(matches[4].identity, "personal")
        XCTAssertEqual(matches[4].type, .publicKey)
        XCTAssertEqual(matches[4].path, path(".ssh/id_rsa_git_personal.pub"))

        XCTAssertEqual(matches[5].identity, "work")
        XCTAssertEqual(matches[5].type, .publicKey)
        XCTAssertEqual(matches[5].path, path(".ssh/id_rsa_git_work.pub"))
    }
}

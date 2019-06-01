//
//  IdentityTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 6/1/19.
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

import GitIdentityCore
import XCTest

class IdentityTests: XCTestCase {

    private static var fs: Sandbox!

    override class func setUp() {
        super.setUp()
        fs = try! Sandbox.testContents()
    }

    override class func tearDown() {
        try! fs.destroy()
        super.tearDown()
    }

    private var fs: Sandbox! {
        return IdentityTests.fs
    }

    private var rootPath: String {
        return fs.root.path
    }

    private var sshPath: String {
        return fs.path(".ssh")
    }

    private var config: Configuration {
        return Configuration(sshPath: sshPath, gitconfigPath: rootPath)
    }

    func verify(_ identityFile: IdentityFile, _ identity: String, _ type: IdentityFileType, _ path: String, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(identityFile.identity, identity, file: file, line: line)
        XCTAssertEqual(identityFile.type, type, file: file, line: line)
        XCTAssertEqual(identityFile.path, fs.path(path), file: file, line: line)
    }

    func testRead() throws {
        let current = try Identity.read(name: "current", config: config)
        verify(current.gitconfigFile, "current", .gitconfig, fs.path(".gitconfig_identity_current"))
        verify(current.privateKeyFile, "current", .privateKey, fs.path(".ssh/id_rsa_git_current"))
        verify(current.publicKeyFile, "current", .publicKey, fs.path(".ssh/id_rsa_git_current.pub"))

        let personal = try Identity.read(name: "personal", config: config)
        verify(personal.gitconfigFile, "personal", .gitconfig, fs.path(".gitconfig_identity_personal"))
        verify(personal.privateKeyFile, "personal", .privateKey, fs.path(".ssh/id_rsa_git_personal"))
        verify(personal.publicKeyFile, "personal", .publicKey, fs.path(".ssh/id_rsa_git_personal.pub"))
    }

    func testAllIdentities() {
        let identities = Identity.identities(config: config)
        XCTAssertEqual(identities.count, 2)

        guard identities.count == 2 else {
            XCTFail("Incorrect number of identities -- skipping remainder of test")
            return
        }
        
        XCTAssertEqual(identities[0].name, "personal")
        XCTAssertEqual(identities[1].name, "work")
    }
}

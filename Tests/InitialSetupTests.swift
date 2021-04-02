//
//  InitialSetupTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 6/3/19.
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

class InitialSetupTests: SandboxTestCase {

    override func setUp() {
        super.setUp()

        do {
            try fs.remove(".gitconfig_identity_current")
            try fs.remove(".ssh/id_rsa_git_current")
            try fs.remove(".ssh/id_rsa_git_current.pub")
        }
        catch {
            fatalError("Could not remove file: \(error)")
        }
    }

    func testCurrentIdentity() {
        XCTAssertThrowsError(try createTestConfig().loadCurrentIdentity())
    }

    func testInitialSetup() throws {
        let config = try self.createTestConfig()

        XCTAssertThrowsError(try config.loadCurrentIdentity())

        try config.setCurrentIdentity(name: "work")

        let current = try config.loadCurrentIdentity()
        XCTAssertEqual(current.name, "work")
        XCTAssertEqual(current.destination.gitconfig, fs.file(at: ".gitconfig_identity_work"))
        XCTAssertEqual(current.destination.privateKey, fs.file(at: ".ssh/id_rsa_git_work"))
        XCTAssertEqual(current.destination.publicKey, fs.file(at: ".ssh/id_rsa_git_work.pub"))
    }
}

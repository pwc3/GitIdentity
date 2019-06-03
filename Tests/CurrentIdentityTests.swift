//
//  CurrentIdentityTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 6/2/19.
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

class CurrentIdentityTests: SandboxTestCase {

    func testCurrentIdentity() throws {
        let current = try CurrentIdentity(config: config)
        XCTAssertEqual(current.destination.name, "personal")
        verify(current.destination.gitconfigFile, "personal", .gitconfig, ".gitconfig_identity_personal")
        verify(current.destination.publicKeyFile, "personal", .publicKey, ".ssh/id_rsa_git_personal.pub")
        verify(current.destination.privateKeyFile, "personal", .privateKey, ".ssh/id_rsa_git_personal")
    }

    func testChangeCurrentIdentity() throws {
        let original = try CurrentIdentity(config: config)
        XCTAssertEqual(original.destination.name, "personal")
        verify(original.destination.gitconfigFile, "personal", .gitconfig, ".gitconfig_identity_personal")
        verify(original.destination.publicKeyFile, "personal", .publicKey, ".ssh/id_rsa_git_personal.pub")
        verify(original.destination.privateKeyFile, "personal", .privateKey, ".ssh/id_rsa_git_personal")

        let work = try Identity.read(name: "work", config: config)
        XCTAssertEqual(work.name, "work")
        verify(work.gitconfigFile, "work", .gitconfig, ".gitconfig_identity_work")
        verify(work.publicKeyFile, "work", .publicKey, ".ssh/id_rsa_git_work.pub")
        verify(work.privateKeyFile, "work", .privateKey, ".ssh/id_rsa_git_work")

        let updated = try CurrentIdentity.set(to: work, config: config)
        XCTAssertEqual(updated.destination.name, "work")
        verify(updated.destination.gitconfigFile, "work", .gitconfig, ".gitconfig_identity_work")
        verify(updated.destination.publicKeyFile, "work", .publicKey, ".ssh/id_rsa_git_work.pub")
        verify(updated.destination.privateKeyFile, "work", .privateKey, ".ssh/id_rsa_git_work")

        let current = try CurrentIdentity(config: config)
        XCTAssertEqual(current.destination.name, "work")
        verify(current.destination.gitconfigFile, "work", .gitconfig, ".gitconfig_identity_work")
        verify(current.destination.publicKeyFile, "work", .publicKey, ".ssh/id_rsa_git_work.pub")
        verify(current.destination.privateKeyFile, "work", .privateKey, ".ssh/id_rsa_git_work")
    }
}

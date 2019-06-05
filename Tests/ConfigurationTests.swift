//
//  ConfigurationTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 6/4/19.
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

class ConfigurationTests: XCTestCase {

    let json = """
{
    "current": {
        "gitconfig": "~/.gitconfig_identity_current",
        "privateKey": "~/.ssh/id_rsa_git_current",
        "publicKey": "~/.ssh/id_rsa_git_current.pub"
    },
    "personal": {
        "gitconfig": "~/.gitconfig_identity_personal",
        "privateKey": "~/.ssh/id_rsa_git_personal",
        "publicKey": "~/.ssh/id_rsa_git_personal.pub"
    },
    "work": {
        "gitconfig": "~/.gitconfig_identity_work",
        "privateKey": "~/.ssh/id_rsa_git_work",
        "publicKey": "~/.ssh/id_rsa_git_work.pub"
    }
}
"""

    func testRead() throws {
        let config = try Configuration.load(data: json.data(using: .utf8)!)
        XCTAssertEqual(config.identityNames.count, 2)
        XCTAssertEqual(config.identityNames, ["personal", "work"])

        let personal = config.identity(forName: "personal")
        XCTAssertNotNil(personal)
        XCTAssertEqual(personal?.gitconfig, File(path: "~/.gitconfig_identity_personal"))
        XCTAssertEqual(personal?.privateKey, File(path: "~/.ssh/id_rsa_git_personal"))
        XCTAssertEqual(personal?.publicKey, File(path: "~/.ssh/id_rsa_git_personal.pub"))

        let work = config.identity(forName: "work")
        XCTAssertNotNil(work)
        XCTAssertEqual(work?.gitconfig, File(path: "~/.gitconfig_identity_work"))
        XCTAssertEqual(work?.privateKey, File(path: "~/.ssh/id_rsa_git_work"))
        XCTAssertEqual(work?.publicKey, File(path: "~/.ssh/id_rsa_git_work.pub"))
    }
}

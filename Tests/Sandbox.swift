//
//  Sandbox.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 5/31/19.
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

import Foundation

class Sandbox {

    let root: URL

    static var defaultRoot: URL {
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return tempDir.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    init(root: URL = defaultRoot) throws {
        self.root = root
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
    }

    func url(_ filename: String) -> URL {
        return URL(fileURLWithPath: filename, relativeTo: root)
    }

    func path(_ filename: String) -> String {
        return url(filename).path
    }

    func mkdirs(_ filename: String) throws {
        try mkdirs(self.url(filename))
    }

    func mkdirs(_ url: URL) throws {
        let parent = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
    }

    @discardableResult
    func create(_ filename: String, contents: String = "") throws -> String {
        let url = self.url(filename)
        try mkdirs(url)
        try contents.write(to: url, atomically: true, encoding: .utf8)

        print("Created \(url.path)")
        return url.path
    }

    func createSymlink(at locationFilename: String, destination destinationFilename: String) throws {
        try FileManager.default.createSymbolicLink(at: url(locationFilename), withDestinationURL: url(destinationFilename))
    }

    func destroy() throws {
        try FileManager.default.removeItem(at: root)
    }
}

extension Sandbox {
    static func testContents() throws -> Sandbox {
        let fs = try Sandbox()

        try fs.create(".bashrc")
        try fs.create(".bash_history")
        try fs.create(".gitconfig_identity_personal")
        try fs.create(".gitconfig_identity_work")
        try fs.create(".ssh/config")
        try fs.create(".ssh/id_rsa_git_personal")
        try fs.create(".ssh/id_rsa_git_personal.pub")
        try fs.create(".ssh/id_rsa_git_work")
        try fs.create(".ssh/id_rsa_git_work.pub")
        try fs.create(".ssh/known_hosts")

        try fs.createSymlink(at: ".gitconfig_identity_current", destination: ".gitconfig_identity_personal")
        try fs.createSymlink(at: ".ssh/id_rsa_git_current", destination: ".ssh/id_rsa_git_personal")
        try fs.createSymlink(at: ".ssh/id_rsa_git_current.pub", destination: ".ssh/id_rsa_git_personal.pub")

        return fs
    }
}

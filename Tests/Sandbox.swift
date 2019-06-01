//
//  Sandbox.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 5/31/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
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

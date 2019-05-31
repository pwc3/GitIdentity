//
//  Operations.swift
//  GitIdentity
//
//  Created by Paul Calnan on 5/31/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public class GitIdentityOperation<SuccessType>: Operation {

    let config: Configuration

    let printOutput: Bool

    public private(set) var result: Result<SuccessType, Error>?

    init(config: Configuration, printOutput: Bool) {
        self.config = config
        self.printOutput = printOutput
    }

    override public func main() {
        let result: Result<SuccessType, Error>
        do {
            result = .success(try execute())
        }
        catch {
            result = .failure(error)
        }

        self.result = result
        if self.printOutput {
            printResult(result)
        }
    }

    func execute() throws -> SuccessType {
        fatalError("execute() must be overriden by subclass")
    }

    func printResult(_ result: Result<SuccessType, Error>) {
        switch result {
        case .success(let value):
            printSuccess(value)

        case .failure(let error):
            printFailure(error)
        }
    }

    func printSuccess(_ value: SuccessType) {
        fatalError("printSuccess(_:) must be overridden by subclass")
    }

    func printFailure(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

public class CurrentOperation: GitIdentityOperation<String> {
    override func execute() throws -> String {
        let current = try CurrentIdentity(config: config)
        return current.targetName
    }

    override func printSuccess(_ value: String) {
        print(value)
    }
}

public class ListOperation: GitIdentityOperation<[String: Bool]> {
    override func execute() throws -> [String: Bool] {
        let current = try CurrentIdentity(config: config).targetName
        let identities = Identity.identities(config: config)

        var result = [String: Bool]()
        for id in identities {
            let name = id.name
            result[name] = (name == current)
        }

        return result
    }

    override func printSuccess(_ value: [String : Bool]) {
        for identity in value.keys.sorted() {
            let prefix = value[identity] ?? false
                ? " * "
                : "   "

            print("\(prefix)\(identity)")
        }
    }
}

public class PrintOperation: GitIdentityOperation<Void> {
    override func execute() throws -> Void {
    }

    override func printSuccess(_ value: Void) {
        print("Successful")
    }
}

public class UseOperation: GitIdentityOperation<Void> {
    let identity: String

    init(config: Configuration, printOutput: Bool, identity: String) {
        self.identity = identity
        super.init(config: config, printOutput: printOutput)
    }

    override func execute() throws -> Void {
    }

    override func printSuccess(_ value: Void) {
        print("Successful")
    }
}

public class HelpOperation: GitIdentityOperation<[String]> {

    override func execute() throws -> [String] {
        return [
            "git-identity: Manages multiple Git identity configurations (SSH keys, .gitconfig files).",
            "",
            "Commands:",
            " * git identity current",
            "     prints the current identity",
            " * git identity list",
            "     lists the available identities",
            " * git identity print",
            "     prints information about the current identity",
            " * git identity use NAME",
            "     changes the current identity to NAME",
            " * git identity help",
            "     prints this message"
        ]
    }

    override func printSuccess(_ value: [String]) {
        print(value.joined(separator: "\n"))
    }
}

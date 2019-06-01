//
//  GitIdentityOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
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

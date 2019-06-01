//
//  GitIdentityOperation.swift
//  GitIdentityCore
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

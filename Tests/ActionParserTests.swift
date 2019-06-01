//
//  ActionParserTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 5/30/19.
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

class ActionParserTests: XCTestCase {

    private func check(actual: Result<Action, GitIdentityError>,
                       expected: Result<Action, GitIdentityError>,
                       file: StaticString = #file,
                       line: UInt = #line)
    {
        switch (expected, actual) {
        case (.success(let a1), .success(let a2)):
            XCTAssertEqual(a1, a2, file: file, line: line)

        case (.failure(let e1), .failure(let e2)):
            XCTAssertEqual(e1 as NSError, e2 as NSError, file: file, line: line)

        default:
            XCTFail("Expected \(expected), received \(actual)", file: file, line: line)
        }
    }

    func testNoArguments() {
        check(actual: ActionParser.parse(arguments: []),
              expected: .failure(.incorrectNumberOfArguments))
    }

    func testCurrent() {
        check(actual: ActionParser.parse(arguments: ["current"]),
              expected: .success(.current))
    }

    func testCurrentWithArgs() {
        check(actual: ActionParser.parse(arguments: ["current", "foo"]),
              expected: .failure(.incorrectNumberOfArguments))
    }

    func testList() {
        check(actual: ActionParser.parse(arguments: ["list"]),
              expected: .success(.list))
    }

    func testListWithArgs() {
        check(actual: ActionParser.parse(arguments: ["list", "foo"]),
              expected: .failure(.incorrectNumberOfArguments))
    }

    func testPrint() {
        check(actual: ActionParser.parse(arguments: ["print"]),
              expected: .success(.print))
    }

    func testPrintWithArgs() {
        check(actual: ActionParser.parse(arguments: ["print", "foo"]),
              expected: .failure(.incorrectNumberOfArguments))
    }

    func testUse() {
        check(actual: ActionParser.parse(arguments: ["use", "foo"]),
              expected: .success(.use(identity: "foo")))
    }

    func testUseWithoutArgs() {
        check(actual: ActionParser.parse(arguments: ["use"]),
              expected: .failure(.incorrectNumberOfArguments))
    }

    func testUnrecognizedCommand() {
        check(actual: ActionParser.parse(arguments: ["foo", "bar", "baz"]),
              expected: .failure(.unrecognizedCommand("foo")))
    }
}

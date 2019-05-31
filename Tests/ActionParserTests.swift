//
//  ActionParserTests.swift
//  GitIdentityTests
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
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
            XCTAssertEqual(e1, e2, file: file, line: line)

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

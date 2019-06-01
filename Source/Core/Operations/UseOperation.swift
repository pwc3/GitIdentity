//
//  UseOperation.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 6/1/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

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

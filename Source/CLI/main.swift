//
//  main.swift
//  git-identity
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import GitIdentityCore
import Foundation

let config = Configuration()
do {
    let identities = try Identity.identities(config: config)
    print(identities.map { $0.name })
}
catch {
    print("Error: \(error)")
}

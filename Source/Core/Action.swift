//
//  Action.swift
//  GitIdentityCore
//
//  Created by Paul Calnan on 5/30/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public enum Action: Equatable {

    case current

    case list

    case print

    case use(identity: String)
}

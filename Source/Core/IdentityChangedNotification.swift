//
//  IdentityChangedNotification.swift
//  GitIdentity
//
//  Created by Paul Calnan on 6/3/19.
//  Copyright © 2019 Anodized Software, Inc. All rights reserved.
//

import Foundation

public struct IdentityChangedNotification {

    public static let name = Notification.Name("com.anodizedsoftware.GitIdentity.IdentityChangedNotification")

    public static let currentIdentityKey = "currentIdentity"

    static func post(currentIdentity: String) {
        DistributedNotificationCenter.default().post(name: IdentityChangedNotification.name, object: nil, userInfo: [
            IdentityChangedNotification.currentIdentityKey: currentIdentity
        ])
    }
}

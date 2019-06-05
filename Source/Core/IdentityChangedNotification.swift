//
//  IdentityChangedNotification.swift
//  GitIdentity
//
//  Created by Paul Calnan on 6/3/19.
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

/// A `Notification` sent via `DistributedNotificationCenter` to communicate between the CLI and GUI.
public struct IdentityChangedNotification {

    /// The name of the notification.
    public static let name = Notification.Name("com.anodizedsoftware.GitIdentity.IdentityChangedNotification")

    /// The user info dictionary key associated with the current identity name.
    public static let currentIdentityKey = "currentIdentity"

    /**
     Posts this notification on the default `DistributedNotificationCenter`.

     - Parameter currentIdentity: The name of the new current identity.
     */
    static func post(currentIdentity: String) {
        DistributedNotificationCenter.default().post(name: IdentityChangedNotification.name, object: nil, userInfo: [
            IdentityChangedNotification.currentIdentityKey: currentIdentity
        ])
    }
}

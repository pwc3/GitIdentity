//
//  IdentityMenu.swift
//  GitIdentity
//
//  Created by Paul Calnan on 6/2/19.
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
import Cocoa

class IdentityMenu: NSObject {

    private let iconSize: CGFloat = 16

    private let titleFontSize: CGFloat = 14

    private let titleBaselineOffset: CGFloat = -0.5

    private let operationQueue: OperationQueue

    private let config: Configuration

    let statusItem: NSStatusItem

    init(config: Configuration) {
        operationQueue = OperationQueue()
        self.config = config

        let icon = NSImage(named: "Git-Icon-Black")
        icon?.size = NSSize(width: iconSize, height: iconSize)

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.image = icon
        statusItem.button?.imagePosition = .imageLeft
        statusItem.button?.isEnabled = true
        statusItem.button?.toolTip = "Git Identity"

        super.init()
        updateState()

        DistributedNotificationCenter.default().addObserver(self, selector: #selector(identityChanged(notification:)), name: IdentityChangedNotification.name, object: nil, suspensionBehavior: .deliverImmediately)
    }

    @objc private func identityChanged(notification: Notification) {
        updateState()
    }

    private func attributedTitle(_ value: String) -> NSAttributedString {
        return NSAttributedString(string: " \(value)", attributes: [
            .baselineOffset: titleBaselineOffset,
            .font: NSFont.systemFont(ofSize: titleFontSize)
            ])
    }

    private func updateState() {
        let op = ListOperation(config: config, printOutput: false)
        op.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.updateState(with: op.result)
            }
        }

        operationQueue.addOperation(op)
    }

    private func updateState(with result: Result<[String: Bool], Error>?) {
        guard let result = result else {
            return
        }

        switch result {
        case .success(let value):
            print("Update state with value: \(value)")
            updateTitle(with: value)
            updateMenu(with: value)

        case .failure(let error):
            print("Update state with error: \(error.localizedDescription)")
            updateTitle(with: error)
            updateMenu(with: error)

            let alert = NSAlert(error: error)
            alert.window.title = "Git Identity"
            alert.runModal()
        }
    }

    private func updateTitle(with identities: [String: Bool]) {
        for identity in identities.keys {
            if identities[identity] ?? false {
                setTitle(identity)
                return
            }
        }

        setTitle("??")
    }

    private func updateTitle(with error: Error) {
        setTitle("(Error)")
    }

    private func setTitle(_ string: String) {
        statusItem.button?.attributedTitle = attributedTitle(string)
    }

    private func updateMenu(with identities: [String: Bool]) {
        let menu = NSMenu()

        menu.addItem(headerItem())
        menu.addItem(NSMenuItem.separator())

        for identity in identities.keys.sorted() {
            let menuItem = NSMenuItem(title: identity, action: #selector(selectIdentity(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.state = (identities[identity] ?? false) ? .on : .off
            menu.addItem(menuItem)
        }

        if identities.count > 0 {
            menu.addItem(NSMenuItem.separator())
        }
        menu.addItem(quitItem())

        statusItem.menu = menu
    }

    private func updateMenu(with error: Error) {
        let menu = NSMenu()

        menu.addItem(headerItem())
        menu.addItem(NSMenuItem.separator())
        menu.addItem(quitItem())

        statusItem.menu = menu
    }

    private func headerItem() -> NSMenuItem {
        let version: String
        if let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            version = "v\(v)"
        }
        else {
            version = ""
        }

        return NSMenuItem(title: "Git Identity \(version)", action: nil, keyEquivalent: "")
    }

    private func quitItem() -> NSMenuItem {
        let item = NSMenuItem(title: "Quit", action: #selector(quit(_:)), keyEquivalent: "q")
        item.target = self
        return item
    }

    @objc private func selectIdentity(_ sender: NSMenuItem) {
        let identity = sender.title
        print("Select identity: \(identity)")

        let op = UseOperation(config: config, printOutput: false, identity: identity)
        op.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.updateState()
            }
        }
        operationQueue.addOperation(op)
    }

    @objc private func quit(_ sender: NSMenuItem) {
        print("Quit")
        exit(0)
    }
}

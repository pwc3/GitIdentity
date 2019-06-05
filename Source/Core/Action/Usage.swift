//
//  Usage.swift
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

import Foundation

/// Contains the usage string constant.
public struct Usage {

    /// The usage string.
    public static let usage: String = [
        "git-identity: Manages multiple Git identity configurations (SSH keys, .gitconfig files).",
        "",
        "Commands:",
        " * git identity current",
        "     prints the current identity",
        " * git identity list",
        "     lists the available identities",
        " * git identity print",
        "     prints information about the current identity",
        " * git identity use NAME",
        "     changes the current identity to NAME",
        " * git identity version",
        "     prints the current tool version",
        " * git identity help",
        "     prints this message"
    ].joined(separator: "\n")
}

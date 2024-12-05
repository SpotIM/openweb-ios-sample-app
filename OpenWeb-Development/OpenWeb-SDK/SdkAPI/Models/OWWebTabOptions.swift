//
//  OWSafariViewControllerOptions.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public struct OWWebTabOptions {
    public var url: URL
    public var title: String
    public var events: [String]

    public init(url: URL, title: String = "", events: [String] = []) {
        self.url = url
        self.title = title
        self.events = events
    }
}

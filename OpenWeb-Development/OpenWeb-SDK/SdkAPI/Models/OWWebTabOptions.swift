//
//  OWSafariViewControllerOptions.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public struct OWWebTabOptions {
    public let url: URL
    public let title: String

    public init(url: URL, title: String = "") {
        self.url = url
        self.title = title

    }
}

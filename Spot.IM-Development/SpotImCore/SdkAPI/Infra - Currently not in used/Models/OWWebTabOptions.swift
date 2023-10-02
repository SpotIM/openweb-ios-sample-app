//
//  OWSafariViewControllerOptions.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWWebTabOptions {
    public let url: URL
    public let title: String

    public init(url: URL, title: String) {
        self.url = url
        self.title = title

    }
}

#else
struct OWWebTabOptions {
    let url: URL
    let title: String

    init(url: URL, title: String) {
        self.url = url
        self.title = title

    }
}
#endif

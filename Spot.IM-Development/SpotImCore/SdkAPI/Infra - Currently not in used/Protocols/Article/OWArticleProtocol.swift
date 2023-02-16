//
//  OWArticleProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public protocol OWArticleProtocol {
    var url: URL { get }
    var title: String { get }
    var subtitle: String? { get }
    var thumbnailUrl: URL? { get }
    var additionalSettings: OWArticleSettingsProtocol { get }
}
#else
protocol OWArticleProtocol {
    var url: URL { get }
    var title: String { get }
    var subtitle: String? { get }
    var thumbnailUrl: URL? { get }
    var additionalSettings: OWArticleSettingsProtocol { get }
}
#endif


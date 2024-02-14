//
//  OWArticleProtocol.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWArticleProtocol {
    var articleInformationStrategy: OWArticleInformationStrategy { get }
    var additionalSettings: OWArticleSettingsProtocol { get }
}

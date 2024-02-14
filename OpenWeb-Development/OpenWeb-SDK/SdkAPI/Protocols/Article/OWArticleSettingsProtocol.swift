//
//  OWArticleSettingsProtocol.swift
//  SpotImCore
//
//  Created by Alon Haiut on 05/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWArticleSettingsProtocol {
    var section: String { get }
    var headerStyle: OWArticleHeaderStyle { get }
    var readOnlyMode: OWReadOnlyMode { get }
}

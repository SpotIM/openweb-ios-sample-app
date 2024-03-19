//
//  OWCommentCreationSettingsProtocol.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 07/09/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWCommentCreationSettingsProtocol {
    var style: OWCommentCreationStyle { get }
    func request(_ request: OWCommentCreationRequestOption)
}

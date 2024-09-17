//
//  OWCommentActionsCustomizations.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 14/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

public protocol OWCommentActionsCustomizations {
    var fontStyle: OWCommentActionsFontStyle { get set }
    var color: OWCommentActionsColor { get set }
}

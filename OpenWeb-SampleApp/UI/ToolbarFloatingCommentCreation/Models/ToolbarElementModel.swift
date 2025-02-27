//
//  ToolbarElementModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

struct ToolbarElementModel: Hashable {
    let emoji: String
    let accessibility: String
    let action: ToolbarElementAction
}

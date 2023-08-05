//
//  OWManipulateTextModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 30/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public struct OWManipulateTextModel {
    public let text: String
    public let cursorRange: Range<String.Index>
}

#else
struct OWManipulateTextModel {
    let text: String
    let cursorRange: Range<String.Index>
}
#endif

//
//  OWSummaryCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWSummaryCustomizableElement {
    case commentsTitle(label: UILabel)
    case sortByTitle(label: UILabel)
}
#else
enum OWSummaryCustomizableElement {
    case commentsTitle(label: UILabel)
    case sortByTitle(label: UILabel)
}
#endif

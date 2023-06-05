//
//  OWSummeryHeaderCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 24/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWSummeryHeaderCustomizableElement {
    case title(label: UILabel)
    case counter(label: UILabel)
}
#else
enum OWSummeryHeaderCustomizableElement {
    case title(label: UILabel)
    case counter(label: UILabel)
}
#endif



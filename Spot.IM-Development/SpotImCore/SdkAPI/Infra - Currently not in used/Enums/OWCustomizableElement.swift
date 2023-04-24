//
//  OWCustomizableElement.swift
//  SpotImCore
//
//  Created by Alon Haiut on 08/11/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWCustomizableElement {
    case headerTitle(label: UILabel)
    case headerCounter(label: UILabel)
}
#else
enum OWCustomizableElement {
    case headerTitle(label: UILabel)
    case headerCounter(label: UILabel)
}
#endif

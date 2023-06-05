//
//  OWOnlineUsersCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWOnlineUsersCustomizableElement {
    case icon(image: UIImageView)
    case counter(label: UILabel)
}
#else
enum OWNavigationBarCustomizableElement {
    case icon(image: UIImageView)
    case counter(label: UILabel)
}
#endif


//
//  OWHeaderCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWHeaderCustomizableElement {
    case title(label: UILabel)
    case close(button: UIButton)
}
#else
public enum OWHeaderCustomizableElement {
    case title(label: UILabel)
    case close(button: UIButton)
}
#endif

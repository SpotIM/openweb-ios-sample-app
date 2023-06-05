//
//  OWEmptyStateCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 24/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWEmptyStateCustomizableElement {
    case icon(image: UIImageView)
    case title(label: UILabel)
}
#else
enum OWEmptyStateCustomizableElement {
    case icon(image: UIImageView)
    case title(label: UILabel)
}
#endif




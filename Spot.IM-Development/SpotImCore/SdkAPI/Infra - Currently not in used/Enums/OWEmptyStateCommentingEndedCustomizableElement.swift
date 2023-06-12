//
//  OWEmptyStateCommentingEndedCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWEmptyStateCommentingEndedCustomizableElement {
    case icon(image: UIImage)
    case title(label: UILabel)
}
#else
enum OWEmptyStateCommentingEndedCustomizableElement {
    case icon(image: UIImage)
    case title(label: UILabel)
}
#endif

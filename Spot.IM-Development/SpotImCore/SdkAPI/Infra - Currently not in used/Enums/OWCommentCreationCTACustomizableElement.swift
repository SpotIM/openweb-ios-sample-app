//
//  OWCommentCreationCTACustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 24/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWCommentCreationCTACustomizableElement {
    case container(view: UIView)
    case placeholder(label: UILabel)
}
#else
enum OWCommentCreationCTACustomizableElement {
    case container(view: UIView)
    case placeholder(label: UILabel)
}
#endif




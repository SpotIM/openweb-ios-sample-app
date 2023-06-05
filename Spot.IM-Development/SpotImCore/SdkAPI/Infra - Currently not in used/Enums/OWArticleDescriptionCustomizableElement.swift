//
//  OWArticleDescriptionCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWArticleDescriptionCustomizableElement {
    case image(imageView: UIImageView)
    case title(label: UILabel)
    case author(label: UILabel)
}
#else
enum OWArticleDescriptionCustomizableElement {
    case image(imageView: UIImageView)
    case title(label: UILabel)
    case author(label: UILabel)
}
#endif



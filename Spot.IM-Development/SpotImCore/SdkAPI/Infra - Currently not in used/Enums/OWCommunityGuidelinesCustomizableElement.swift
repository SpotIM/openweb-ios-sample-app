//
//  OWCommunityGuidelinesCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 23/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWCommunityGuidelinesCustomizableElement {
    case regular(textView: UITextView)
    case compact(icon: UIImageView, textView: UITextView)
}
#else
enum OWCommunityGuidelinesCustomizableElement {
    case regular(textView: UITextView)
    case compact(icon: UIImageView, textView: UITextView)
}
#endif

//
//  OWCommunityQuestionCustomizableElement.swift
//  SpotImCore
//
//  Created by Revital Pisman on 29/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit

#if NEW_API
public enum OWCommunityQuestionCustomizableElement {
    case regular(textView: UITextView)
    case compact(containerView: UIView, label: UILabel)
}
#else
enum OWCommunityGuidelinesCustomizableElement {
    case regular(textView: UITextView)
    case compact(containerView: UIView, label: UILabel)
}
#endif


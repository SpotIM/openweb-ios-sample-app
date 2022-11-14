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
    // TODO: Complete
}
#else
enum OWCustomizableElement {
    case communityQuestion(textView: UITextView)
    case communityGuidelines(textView: UITextView)
    // TODO: Complete
}
#endif

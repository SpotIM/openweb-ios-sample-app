//
//  BaseTextField.swift
//  SpotImCore
//
//  Created by Andriy Fedin on 04/12/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class SPBaseTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)

        semanticContentAttribute = SPLocalizationManager.currentLanguage?.customSemanticAttribute
            ?? semanticContentAttribute
        textAlignment = (semanticContentAttribute == .forceRightToLeft) ? .right : .left
    }

    @available(*,
    unavailable,
    message: "Loading this view from a nib is unsupported in this project"
    )
    required
    public init?(coder aDecoder: NSCoder) {
        fatalError("Loading this view from a nib is unsupported in this project")
    }

}

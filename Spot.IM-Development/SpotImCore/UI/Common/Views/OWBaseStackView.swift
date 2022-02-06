//
//  BaseStackView.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 04/12/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal class OWBaseStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
            ?? semanticContentAttribute
        backgroundColor = .spBackground0
    }

    @available(*,
    unavailable,
    message: "Loading this view from a nib is unsupported in this project"
    )
    required
    public init(coder aDecoder: NSCoder) {
        fatalError("Loading this view from a nib is unsupported in this project")
    }
    
}

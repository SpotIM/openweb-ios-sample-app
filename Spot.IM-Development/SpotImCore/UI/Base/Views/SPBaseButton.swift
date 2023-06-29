//
//  BaseButton.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

public class SPBaseButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)

        semanticContentAttribute = SPLocalizationManager.currentLanguage?.customSemanticAttribute
        ?? semanticContentAttribute
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

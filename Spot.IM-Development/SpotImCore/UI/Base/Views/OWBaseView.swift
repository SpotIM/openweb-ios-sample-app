//
//  BaseView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

public class OWBaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
            ?? semanticContentAttribute
        backgroundColor = .spBackground0
        translatesAutoresizingMaskIntoConstraints = false
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

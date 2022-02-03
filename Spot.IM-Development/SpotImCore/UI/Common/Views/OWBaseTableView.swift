//
//  BaseTableView.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

class OWBaseTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
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

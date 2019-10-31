//
//  BaseView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/1/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal class BaseView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
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

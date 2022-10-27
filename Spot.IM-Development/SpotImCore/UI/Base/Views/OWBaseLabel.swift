//
//  BaseLabel.swift
//  SpotImCore
//
//  Created by Eugene on 11.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

public class OWBaseLabel: UILabel {
    fileprivate struct Metrics {
        static let identifier = "base_label_id"
    }
    // edge inset can be set to label (padding), default is no padding (insets = 0)
    var insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
        ?? semanticContentAttribute
        self.accessibilityIdentifier = Metrics.identifier
    }
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    public override var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            contentSize.height += insets.top + insets.bottom
            contentSize.width += insets.left + insets.right
            return contentSize
        }
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

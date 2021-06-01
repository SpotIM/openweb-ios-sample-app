//
//  SPCommunityQuestionView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPCommunityQuestionView: BaseView {
    
    private lazy var questionLabel: BaseLabel = .init()
    
    private var questionBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
    }
    
    // MARK: - Private Methods

    private func setup() {
        addSubviews(questionLabel)
        setupQuestionLabel()
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "community question text, very long one .."
        questionLabel.numberOfLines = 0
        questionLabel.backgroundColor = .spBackground0
        questionLabel.font = UIFont.openSans(style: .regularItalic, of: Theme.questionFontSize)
        questionLabel.layout {
            $0.top.equal(to: self.topAnchor, offsetBy: 4.0)
            questionBottomConstraint = $0.bottom.equal(to: self.bottomAnchor)
            $0.leading.equal(to: self.leadingAnchor)
            $0.trailing.equal(to: self.trailingAnchor)
        }
    }

}

private enum Theme {
    static let questionFontSize: CGFloat = 24.0
}

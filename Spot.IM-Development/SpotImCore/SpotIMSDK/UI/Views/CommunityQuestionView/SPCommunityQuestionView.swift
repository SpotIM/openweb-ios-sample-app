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
    private lazy var separatorView: BaseView = .init()
    
    private var questionBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        questionLabel.backgroundColor = .spBackground0
        separatorView.backgroundColor = .spSeparator2
    }
    
    func setCommunityQuestionText(question: String) {
        questionLabel.text = question
    }
    
    // MARK: - Internal methods
    
    internal func setupPreConversationConstraints() {
        questionBottomConstraint?.constant = -Theme.separatorVerticalOffsetPreConversation
    }
    
    // MARK: - Private Methods

    private func setup() {
        addSubviews(questionLabel, separatorView)
        setupQuestionLabel()
        configureSeparatorView()
    }
    
    private func setupQuestionLabel() {
        questionLabel.text = "community question text, very long one .."
        questionLabel.numberOfLines = 0
        questionLabel.backgroundColor = .spBackground0
        questionLabel.font = UIFont.openSans(style: .regularItalic, of: Theme.questionFontSize)
        questionLabel.layout {
            $0.top.equal(to: self.topAnchor)
            questionBottomConstraint = $0.bottom.equal(to: separatorView.topAnchor)
            $0.leading.equal(to: self.leadingAnchor)
            $0.trailing.equal(to: self.trailingAnchor)
        }
    }
    
    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.layout {
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }

}

private enum Theme {
    static let questionFontSize: CGFloat = 20.0
    static let separatorHeight: CGFloat = 1.0
    static let separatorVerticalOffsetPreConversation: CGFloat = 16.0
}

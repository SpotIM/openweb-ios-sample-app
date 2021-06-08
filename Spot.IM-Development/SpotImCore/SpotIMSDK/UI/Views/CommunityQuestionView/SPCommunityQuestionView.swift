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
    private var separatorLeadingConstraint: NSLayoutConstraint?
    private var separatorTrailingConstraint: NSLayoutConstraint?
    
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
        questionBottomConstraint?.constant = -Theme.QuestionBottomOffsetPreConversation
        separatorLeadingConstraint?.constant = Theme.separatorHorizontalOffsetPreConversation
        separatorTrailingConstraint?.constant = -Theme.separatorHorizontalOffsetPreConversation
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
            questionBottomConstraint = $0.bottom.equal(to: separatorView.topAnchor, offsetBy: -Theme.QuestionBottomOffsetFullConversation)
            $0.leading.equal(to: self.leadingAnchor, offsetBy: Theme.questionHorizontalOffset)
            $0.trailing.equal(to: self.trailingAnchor, offsetBy: -Theme.questionHorizontalOffset)
        }
    }
    
    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.layout {
            separatorLeadingConstraint = $0.leading.equal(to: leadingAnchor)
            separatorTrailingConstraint = $0.trailing.equal(to: trailingAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }

}

private enum Theme {
    static let questionFontSize: CGFloat = 20.0
    static let separatorHeight: CGFloat = 1.0
    static let questionHorizontalOffset: CGFloat = 16.0
    static let QuestionBottomOffsetPreConversation: CGFloat = 16.0
    static let QuestionBottomOffsetFullConversation: CGFloat = 5.0
    static let separatorHorizontalOffsetPreConversation: CGFloat = 16.0
}

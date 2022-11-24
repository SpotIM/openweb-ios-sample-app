//
//  SPCommunityQuestionView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

internal final class SPCommunityQuestionView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "community_question_id"
    }
    
    private lazy var questionTextView: OWBaseTextView = .init()
    private lazy var separatorView: OWBaseView = .init()
    
    private var questionBottomConstraint: OWConstraint?
    private var separatorLeadingConstraint: OWConstraint?
    private var separatorTrailingConstraint: OWConstraint?
    
    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityIdentifier = Metrics.identifier
    }
    
    func customizeCommunityQuestion(customUIDelegate: OWCustomUIDelegate, source: SPViewSourceType) {
        customUIDelegate.customizeView(.communityQuestion(textView: questionTextView), source: source)
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        questionTextView.backgroundColor = .spBackground0
        separatorView.backgroundColor = .spSeparator2
    }
    
    func setupCommunityQuestion(with text: String) {
        self.setupSubviews()
        questionTextView.text = text
    }
    
    // MARK: - Internal methods
    
    internal func setupPreConversationConstraints() {
        questionBottomConstraint?.update(offset: -Theme.QuestionBottomOffsetPreConversation)
        separatorLeadingConstraint?.update(offset: Theme.separatorHorizontalOffsetPreConversation)
        separatorTrailingConstraint?.update(offset: -Theme.separatorHorizontalOffsetPreConversation)
    }
    
    // MARK: - Private Methods

    private func setupSubviews() {
        addSubviews(questionTextView, separatorView)
        setupQuestionLabel()
        configureSeparatorView()
        updateColorsAccordingToStyle()
    }
    
    private func setupQuestionLabel() {
        questionTextView.text = ""
        questionTextView.isEditable = false
        questionTextView.isScrollEnabled = false
        questionTextView.font = UIFont.preferred(style: .italic, of: Theme.questionFontSize)
        questionTextView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            questionBottomConstraint = make.bottom.equalTo(separatorView.OWSnp.top).offset(-Theme.QuestionBottomOffsetFullConversation).constraint
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Theme.questionHorizontalOffset)
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Theme.questionHorizontalOffset)
            } else {
                make.leading.equalToSuperview().offset(Theme.questionHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Theme.questionHorizontalOffset)
            }
        }
    }
    
    private func configureSeparatorView() {
        separatorView.OWSnp.makeConstraints { make in
            separatorLeadingConstraint = make.leading.equalToSuperview().constraint
            separatorTrailingConstraint = make.trailing.equalToSuperview().constraint
            make.bottom.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
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

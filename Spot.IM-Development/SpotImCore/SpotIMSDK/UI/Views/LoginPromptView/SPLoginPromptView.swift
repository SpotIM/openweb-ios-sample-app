//
//  SPCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by Oded Regev on 22/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPLoginPromptViewDelegate {
    func clickOnLoginPrompt()
}

internal final class SPLoginPromptView: BaseView {
    
    private lazy var titleTextView: BaseTextView = .init()
    private lazy var separatorView: BaseView = .init()

    private var titleBottomConstraint: NSLayoutConstraint?
    private var separatorLeadingConstraint: NSLayoutConstraint?
    private var separatorTrailingConstraint: NSLayoutConstraint?
    
    var delegate: SPLoginPromptViewDelegate?

    // MARK: - Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        titleTextView.backgroundColor = .spBackground0
        separatorView.backgroundColor = .spSeparator2
    }
    
    func getTextView() -> BaseTextView {
        return self.titleTextView
    }

    
    internal func setupPreConversationConstraints() {
        separatorLeadingConstraint?.constant = Theme.separatorHorizontalOffsetPreConversation
        separatorTrailingConstraint?.constant = -Theme.separatorHorizontalOffsetPreConversation
        titleBottomConstraint?.constant = -Theme.titleBottomOffsetPreConversation
    }
    
    // MARK: - Private Methods

    private func setup() {
        addSubviews(titleTextView, separatorView)
        setupTitleTextView()
        configureSeparatorView()
    }
    
    private func setupTitleTextView() {
        titleTextView.delegate = self
        titleTextView.isEditable = false
        titleTextView.isSelectable = true
        titleTextView.isScrollEnabled = false
        titleTextView.dataDetectorTypes = [.link]
        titleTextView.backgroundColor = .spBackground0

        titleTextView.layout {
            $0.top.equal(to: self.topAnchor)
            titleBottomConstraint = $0.bottom.equal(to: self.bottomAnchor)
            $0.leading.equal(to: self.leadingAnchor, offsetBy: Theme.titleHorizontalOffset)
            $0.trailing.equal(to: self.trailingAnchor, offsetBy: -Theme.titleHorizontalOffset)
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
    static let titleFontSize: CGFloat = 15.0
    static let titleHorizontalOffset: CGFloat = 16.0
    static let separatorHeight: CGFloat = 1.0
    static let separatorHorizontalOffsetPreConversation: CGFloat = 16.0
    static let titleBottomOffsetPreConversation: CGFloat = 8.0
}

extension SPLoginPromptView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.clickOnLoginPrompt()
        return false
    }
    
    // disable selecting text - we need it to allow click on links
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}

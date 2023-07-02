//
//  SPCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by Oded Regev on 22/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPLoginPromptViewDelegate {
    func userTapOnLoginPrompt()
}

internal final class SPLoginPromptView: SPBaseView {

    private lazy var titleTextView: SPBaseTextView = .init()
    private lazy var separatorView: SPBaseView = .init()

    private var titleBottomConstraint: OWConstraint?
    private var separatorLeadingConstraint: OWConstraint?
    private var separatorTrailingConstraint: OWConstraint?

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

    func getTextView() -> SPBaseTextView {
        return self.titleTextView
    }

    internal func setupPreConversationConstraints() {
        separatorLeadingConstraint?.update(offset: Theme.separatorHorizontalOffsetPreConversation)
        separatorTrailingConstraint?.update(offset: -Theme.separatorHorizontalOffsetPreConversation)
        titleBottomConstraint?.update(offset: -Theme.titleBottomOffsetPreConversation)
    }

    // MARK: - Private Methods

    private func setup() {
        addSubviews(titleTextView, separatorView)
        setupTitleTextView()
        configureSeparatorView()
    }

    private func setupTitleTextView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.userPressedLoginText))
        titleTextView.addGestureRecognizer(gesture)

        titleTextView.isEditable = false
        titleTextView.isSelectable = false
        titleTextView.isScrollEnabled = false
        titleTextView.dataDetectorTypes = [.link]
        titleTextView.backgroundColor = .spBackground0

        titleTextView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(4.0)
            titleBottomConstraint = make.bottom.equalToSuperview().offset(-4.0).constraint
            make.leading.equalToSuperview().offset(Theme.titleHorizontalOffset)
            make.trailing.equalToSuperview().offset(-Theme.titleHorizontalOffset)
        }
    }

    @objc func userPressedLoginText(sender: UITapGestureRecognizer) {
        if let delegate = self.delegate {
            delegate.userTapOnLoginPrompt()
        }
    }

    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.OWSnp.makeConstraints { make in
            separatorLeadingConstraint = make.leading.equalToSuperview().constraint
            separatorTrailingConstraint = make.trailing.equalToSuperview().constraint
            make.bottom.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
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

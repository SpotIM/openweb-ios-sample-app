//
//  SPCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/03/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPCommunityGuidelinesViewDelegate {
    func clickOnUrl(url: URL)
    func customizeTextView(textView: UITextView)
}

internal final class SPCommunityGuidelinesView: OWBaseView {
    
    private lazy var titleTextView: OWBaseTextView = .init()
    private lazy var separatorView: OWBaseView = .init()

    private var titleBottomConstraint: OWConstraint?
    private var separatorLeadingConstraint: OWConstraint?
    private var separatorTrailingConstraint: OWConstraint?
    
    var delegate: SPCommunityGuidelinesViewDelegate?

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
        delegate?.customizeTextView(textView: titleTextView)
    }
    
    func setSeperatorVisible(isVisible: Bool) {
        separatorView.isHidden = !isVisible
    }

    // MARK: - Internal methods
    
    internal func setHtmlText(htmlString: String) {
        if let titleTextViewAttributedText = getTitleTextViewAttributedText(htmlString: htmlString) {
            titleTextView.attributedText = titleTextViewAttributedText
        }
        delegate?.customizeTextView(textView: titleTextView)
    }
    
    internal func setupPreConversationConstraints() {
        separatorLeadingConstraint?.update(offset: Theme.separatorHorizontalOffsetPreConversation)
        separatorTrailingConstraint?.update(offset: Theme.separatorHorizontalOffsetPreConversation)
        titleBottomConstraint?.update(offset: -Theme.titleBottomOffsetPreConversation)
    }
    
    // MARK: - Private Methods
    
    private func getTitleTextViewAttributedText(htmlString: String) -> NSMutableAttributedString? {
        if let htmlMutableAttributedString = htmlString.htmlToMutableAttributedString {
            htmlMutableAttributedString.addAttribute(
                .font,
                value: UIFont.preferred(style: .medium, of: Theme.titleFontSize),
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .underlineStyle,
                value: NSNumber(value: false),
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .foregroundColor,
                value: UIColor.spForeground0,
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            return htmlMutableAttributedString
        } else {
            return nil
        }
    }

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

        titleTextView.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            titleBottomConstraint = make.bottom.equalToSuperview().constraint
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Theme.titleHorizontalOffset)
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Theme.titleHorizontalOffset)
            } else {
                make.leading.equalToSuperview().offset(Theme.titleHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Theme.titleHorizontalOffset)
            }
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

extension SPCommunityGuidelinesView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        delegate?.clickOnUrl(url: URL)
        SPAnalyticsHolder.default.log(event: .communityGuidelinesLinkClicked(targetUrl: URL.absoluteString), source: .conversation)
        return false
    }
    
    // disable selecting text - we need it to allow click on links
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}

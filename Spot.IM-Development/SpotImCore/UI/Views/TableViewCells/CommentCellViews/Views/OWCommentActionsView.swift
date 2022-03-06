//
//  OWCommentActionsView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

/// aka Engagement view
final class OWCommentActionsView: OWBaseView {

    weak var delegate: CommentActionsDelegate?

    private let replyDefaultTitle: String
    private let replyButton: OWBaseButton = .init()
    private let rankUpLabel: OWBaseLabel = .init()
    private let rankDownLabel: OWBaseLabel = .init()

    private lazy var rankUpButton: SPAnimatedButton = initializeRankUpButton()
    private lazy var rankDownButton: SPAnimatedButton = initializeRankDownButton()
    private var replyActionViewWidthConstraint: OWConstraint?
    private var replyButtonTrailingConstraint: OWConstraint?
    
    private var isReadOnlyMode: Bool = false

    private var rankedByUser: Int = 0 {
        didSet {
            updateRankButtonState()
        }
    }

    override init(frame: CGRect) {
        replyDefaultTitle = LocalizationManager.localizedString(key: "Reply")
        
        super.init(frame: frame)

        clipsToBounds = true
        setupUI()
        applyAccessibility()
    }
    
    func setReadOnlyMode(enabled: Bool) {
        self.isReadOnlyMode = enabled
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        replyButton.backgroundColor = .spBackground0
        replyButton.setTitleColor(.buttonTitle, for: .normal)
        rankUpButton.backgroundColor = .spBackground0
        rankUpButton.imageColorOff = .buttonTitle
        rankUpLabel.backgroundColor = .spBackground0
        rankUpLabel.textColor = .buttonTitle
        rankDownButton.backgroundColor = .spBackground0
        rankDownButton.imageColorOff = .buttonTitle
        rankDownLabel.backgroundColor = .spBackground0
        rankDownLabel.textColor = .buttonTitle
    }
    
    func setReplyButton(repliesCount: String?, shouldHideButton: Bool = false) {
        var replyButtonTitle: String?
        var isEnabled: Bool = true
        
        switch (self.isReadOnlyMode, repliesCount, shouldHideButton) {
        case (_, _, true), (true, nil, _):
            isEnabled = false
            break
        case (false, _, false):
            isEnabled = true
            replyButtonTitle = replyDefaultTitle
            break
        case (true, .some, false):
            isEnabled = false
            replyButtonTitle = LocalizationManager.localizedString(key: "Replies")
            break
        }
        
        replyButton.isEnabled = isEnabled
        
        if var replyButtonTitle = replyButtonTitle {
            if let repliesCount = repliesCount {
                replyButtonTitle.append(" (\(repliesCount))")
            }
            setShowReplyButton(true)
            replyButton.setTitle(replyButtonTitle, for: .normal)
        } else {
            setShowReplyButton(false)
        }
    }

    func setBrandColor(_ color: UIColor) {
        rankUpButton.imageColorOn = color
        rankUpButton.circleColor = color
        rankUpButton.lineColor = color
        rankDownButton.imageColorOn = color
        rankDownButton.circleColor = color
        rankDownButton.lineColor = color
    }

    func setRankUp(_ rank: Int) {
        rankUpLabel.text = rank.kmFormatted
    }

    func setRankDown(_ rank: Int) {
        rankDownLabel.text = rank.kmFormatted
    }

    func setRanked(with rankedByUser: Int?) {
        if let ranked = rankedByUser, ranked <= 1, ranked >= -1 {
            self.rankedByUser = ranked
        } else {
            self.rankedByUser = 0
        }
    }

    // MARK: - Private
    
    private func setShowReplyButton(_ showButton: Bool) {
        showButton ? replyActionViewWidthConstraint?.deactivate() : replyActionViewWidthConstraint?.activate()
        replyButtonTrailingConstraint?.update(offset: showButton ? -Theme.baseOffset : 0.0)
    }

    private func updateRankButtonState() {
        switch rankedByUser {
        case -1:
            rankUpButton.isSelected = false
            rankDownButton.isSelected = true
        case 1:
            rankUpButton.isSelected = true
            rankDownButton.isSelected = false
        default:
            rankUpButton.isSelected = false
            rankDownButton.isSelected = false
        }
    }

    // MARK: - Private configurations

    private func setupUI() {
        addSubviews(replyButton, rankUpButton, rankUpLabel, rankDownButton, rankDownLabel)
        configureReplyButton()
        configureRankUpButton()
        configureRankDownButton()
        updateColorsAccordingToStyle()
    }

    private func configureReplyButton() {
        replyButton.addTarget(self, action: #selector(reply), for: .touchUpInside)
        replyButton.titleLabel?.font = .preferred(style: .regular, of: Theme.fontSize)
        replyButton.setTitle(replyDefaultTitle, for: .normal)
        
        replyButton.OWSnp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            replyButtonTrailingConstraint = make.trailing.equalTo(rankUpButton.OWSnp.leading).offset(-Theme.baseOffset).constraint
            replyActionViewWidthConstraint = make.width.equalTo(0.0).constraint
            replyActionViewWidthConstraint?.deactivate()
        }
    }

    private func configureRankUpButton() {
        rankUpButton.addTarget(self, action: #selector(rankUp), for: .touchUpInside)
        rankUpButton.setContentHuggingPriority(.required, for: .horizontal)
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        rankUpButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(replyButton)
            make.height.equalTo(Theme.engagementStackHeight)
            make.width.equalTo(width)
            make.trailing.equalTo(rankUpLabel.OWSnp.leading)
        }

        rankUpLabel.textAlignment = .center
        rankUpLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        rankUpLabel.setContentHuggingPriority(.required, for: .horizontal)
        rankUpLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(replyButton)
            make.trailing.equalTo(rankDownButton.OWSnp.leading).offset(-11.0)
        }
    }

    private func configureRankDownButton() {
        rankDownButton.addTarget(self, action: #selector(rankDown), for: .touchUpInside)
        rankDownButton.setContentHuggingPriority(.required, for: .horizontal)
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        rankDownButton.OWSnp.makeConstraints { make in
            make.centerY.equalTo(replyButton).offset(-4.0)
            make.height.equalTo(Theme.engagementStackHeight)
            make.width.equalTo(width)
            make.trailing.equalTo(rankDownLabel.OWSnp.leading)
        }
        

        rankDownLabel.textAlignment = .center
        rankDownLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        rankDownLabel.setContentHuggingPriority(.required, for: .horizontal)
        rankDownLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(replyButton)
        }
    }

    private func initializeRankUpButton() -> SPAnimatedButton {
        let rankUpNormalImage = UIImage(spNamed: "rank_up_normal", supportDarkMode: false)
        let rankUpSelectedImage = UIImage(spNamed: "rank_up_selected", supportDarkMode: false)
        let insets = UIEdgeInsets(
            top: Theme.rankButtonVerticalInset - Theme.rankUpButtonOffset,
            left: Theme.rankButtonHorizontalInset,
            bottom: Theme.rankButtonVerticalInset + Theme.rankUpButtonOffset,
            right: Theme.rankButtonHorizontalInset
        )
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        let frame = CGRect(x: 0, y: 0, width: width, height: Theme.engagementStackHeight)

        return SPAnimatedButton(frame: frame,
                                image: rankUpNormalImage,
                                selectedImage: rankUpSelectedImage,
                                buttonInset: insets)
    }

    private func initializeRankDownButton() -> SPAnimatedButton {
        let rankDownIconNormal = UIImage(spNamed: "rank_down_normal", supportDarkMode: false)
        let rankDownIconSelected = UIImage(spNamed: "rank_down_selected", supportDarkMode: false)
        let insets = UIEdgeInsets(top: Theme.rankButtonVerticalInset - Theme.rankDownButtonOffset,
                                  left: Theme.rankButtonHorizontalInset,
                                  bottom: Theme.rankButtonVerticalInset + Theme.rankDownButtonOffset,
                                  right: Theme.rankButtonHorizontalInset)
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        let frame = CGRect(x: 0, y: 0, width: width, height: Theme.engagementStackHeight)

        return SPAnimatedButton(frame: frame,
                                image: rankDownIconNormal,
                                selectedImage: rankDownIconSelected,
                                buttonInset: insets)
    }

    // MARK: - Actions

    @objc
    private func reply() {
        delegate?.reply()
    }

    @objc
    private func rankUp() {
        let from: SPRank = SPRank(rawValue: rankedByUser) ?? .unrank
        let to: SPRank = (rankedByUser == 0 || rankedByUser == -1) ? .up : .unrank
        
        delegate?.rankUp(SPRankChange(from: from, to: to), updateRankLocal: rankUpLocal)
    }
    
    private func rankUpLocal() {
        switch rankedByUser {
        case -1, 0:
            rankUpButton.select()
            rankedByUser = 1
        default:
            rankUpButton.deselect()
            rankedByUser = 0
        }
    }

    @objc
    private func rankDown() {
        let from: SPRank = SPRank(rawValue: rankedByUser) ?? .unrank
        let to: SPRank = (rankedByUser == 0 || rankedByUser == 1) ? .down : .unrank
        
        delegate?.rankDown(SPRankChange(from: from, to: to), updateRankLocal: rankDownLocal)
    }
    
    private func rankDownLocal() {
        switch rankedByUser {
        case 0, 1:
            rankDownButton.select()
            rankedByUser = -1
        default:
            rankDownButton.deselect()
            rankedByUser = 0
        }
    }
}

// MARK: Accessibility

extension OWCommentActionsView {
  func applyAccessibility() {
    rankUpButton.accessibilityTraits = .button
    rankUpButton.accessibilityLabel = LocalizationManager.localizedString(key: "Up vote button")
    
    rankDownButton.accessibilityTraits = .button
    rankDownButton.accessibilityLabel = LocalizationManager.localizedString(key: "Down vote button")
  }
}

// MARK: - Delegate

protocol CommentActionsDelegate: AnyObject {

    func reply()
    func rankUp(_ rankChange: SPRankChange, updateRankLocal: () -> Void)
    func rankDown(_ rankChange: SPRankChange, updateRankLocal: () -> Void)

}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
    static let rankButtonVerticalInset: CGFloat = 6.0
    static let rankButtonHorizontalInset: CGFloat = 3.0
    static let rankUpButtonOffset: CGFloat = 3.0
    static let rankDownButtonOffset: CGFloat = -3.0
    static let engagementStackHeight: CGFloat = 33
    static let baseOffset: CGFloat = 14
}

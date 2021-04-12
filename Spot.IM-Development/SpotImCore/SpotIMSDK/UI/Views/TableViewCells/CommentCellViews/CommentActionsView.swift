//
//  CommentActionsView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

/// aka Engagement view
final class CommentActionsView: BaseView {

    weak var delegate: CommentActionsDelegate?

    private let replyDefaultTitle: String
    private let replyButton: BaseButton = .init()
    private let rankUpLabel: BaseLabel = .init()
    private let rankDownLabel: BaseLabel = .init()

    private lazy var rankUpButton: SPAnimatedButton = initializeRankUpButton()
    private lazy var rankDownButton: SPAnimatedButton = initializeRankDownButton()
    private var replyActionViewWidthConstraint: NSLayoutConstraint?
    private var replyButtonTrailingConstraint: NSLayoutConstraint?

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
    

    /// Will collapse and disable button if disabled
    func setReplyButton(enabled: Bool) {
        replyButton.isUserInteractionEnabled = enabled
        replyActionViewWidthConstraint?.isActive = !enabled
        replyButtonTrailingConstraint?.constant = enabled ? -Theme.baseOffset : 0.0
    }
    
    func setRepliesCount(_ count: String?) {
        var replyButtonTitle = replyDefaultTitle
        if let repliesCount = count {
            replyButtonTitle.append(" (\(repliesCount))")
        }
        replyButton.setTitle(replyButtonTitle, for: .normal)
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
        replyButton.layout {
            $0.top.equal(to: topAnchor)
            $0.bottom.equal(to: bottomAnchor)
            $0.leading.equal(to: leadingAnchor)
            replyButtonTrailingConstraint = $0.trailing.equal(to: rankUpButton.leadingAnchor,
                                                              offsetBy: -Theme.baseOffset)
            replyActionViewWidthConstraint = $0.width.equal(to: 0.0, isActive: false)
        }
    }

    private func configureRankUpButton() {
        rankUpButton.addTarget(self, action: #selector(rankUp), for: .touchUpInside)
        rankUpButton.setContentHuggingPriority(.required, for: .horizontal)
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        rankUpButton.layout {
            $0.centerY.equal(to: replyButton.centerYAnchor)
            $0.height.equal(to: Theme.engagementStackHeight)
            $0.width.equal(to: width)
            $0.trailing.equal(to: rankUpLabel.leadingAnchor)
        }

        rankUpLabel.textAlignment = .center
        rankUpLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        rankUpLabel.setContentHuggingPriority(.required, for: .horizontal)
        rankUpLabel.layout {
            $0.centerY.equal(to: replyButton.centerYAnchor)
            $0.trailing.equal(to: rankDownButton.leadingAnchor, offsetBy: -11.0)
        }
    }

    private func configureRankDownButton() {
        rankDownButton.addTarget(self, action: #selector(rankDown), for: .touchUpInside)
        rankDownButton.setContentHuggingPriority(.required, for: .horizontal)
        let width = Theme.engagementStackHeight - Theme.rankButtonHorizontalInset * 2
        rankDownButton.layout {
            $0.centerY.equal(to: replyButton.centerYAnchor, offsetBy: -4)
            $0.height.equal(to: Theme.engagementStackHeight)
            $0.width.equal(to: width)
            $0.trailing.equal(to: rankDownLabel.leadingAnchor)
        }

        rankDownLabel.textAlignment = .center
        rankDownLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        rankDownLabel.setContentHuggingPriority(.required, for: .horizontal)
        rankDownLabel.layout {
            $0.centerY.equal(to: replyButton.centerYAnchor)
        }
    }

    private func initializeRankUpButton() -> SPAnimatedButton {
        let rankUpNormalImage = UIImage(spNamed: "rank_up_normal", for: .light)
        let rankUpSelectedImage = UIImage(spNamed: "rank_up_selected", for: .light)
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
        let rankDownIconNormal = UIImage(spNamed: "rank_down_normal", for: .light)
        let rankDownIconSelected = UIImage(spNamed: "rank_down_selected", for: .light)
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
        var to: SPRank = .unrank
        switch rankedByUser {
        case -1, 0:
            rankUpButton.select()
            rankedByUser = 1
            to = .up
        default:
            rankUpButton.deselect()
            rankedByUser = 0
            to = .unrank
        }

        delegate?.rankUp(SPRankChange(from: from, to: to))
    }

    @objc
    private func rankDown() {
        let from: SPRank = SPRank(rawValue: rankedByUser) ?? .unrank
        var to: SPRank = .unrank
        switch rankedByUser {
        case 0, 1:
            rankDownButton.select()
            rankedByUser = -1
            to = .down
        default:
            rankDownButton.deselect()
            rankedByUser = 0
            to = .unrank
        }

        delegate?.rankDown(SPRankChange(from: from, to: to))
    }
}

// MARK: - Delegate

protocol CommentActionsDelegate: class {

    func reply()
    func rankUp(_ rankChange: SPRankChange)
    func rankDown(_ rankChange: SPRankChange)

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

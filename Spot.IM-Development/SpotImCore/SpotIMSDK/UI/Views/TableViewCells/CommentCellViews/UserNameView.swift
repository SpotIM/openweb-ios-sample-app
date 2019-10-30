//
//  UserNameView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class UserNameView: BaseView {

    enum ContentType {
        case comment, reply
    }

    weak var delegate: UserNameViewDelegate?

    private let userNameLabel: UILabel = .init()
    private let subtitleLabel: UILabel = .init()
    private let dateLabel: UILabel = .init()
    private let leaderBadge: UIImageView = .init()
    private let badgeTagLabel: UILabel = .init()
    private let moreButton: UIButton = .init()
    private let userNameButton: UIButton = .init()
    private let deletedMessageLabel: UILabel = .init()

    private var subtitleToNameConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    func setDeleted(_ isDeleted: Bool) {
        deletedMessageLabel.isHidden = !isDeleted
        userNameLabel.isHidden = isDeleted
        dateLabel.isHidden = isDeleted
        subtitleLabel.isHidden = isDeleted
        leaderBadge.isHidden = isDeleted
        moreButton.isHidden = isDeleted
        userNameButton.isHidden = isDeleted
        badgeTagLabel.isHidden = isDeleted
    }

    func setUserName(
        _ name: String?,
        badgeTitle: String?,
        isLeader: Bool = false,
        contentType: ContentType,
        isDeleted: Bool) {

        leaderBadge.tintColor = .brandColor
        switch contentType {
        case .comment:
            userNameLabel.font = .preferred(style: .bold, of: Theme.fontSize)

        case .reply:
            userNameLabel.font = .preferred(style: .medium, of: Theme.fontSize)
        }

        userNameLabel.text = name
        badgeTagLabel.text = badgeTitle
        subtitleToNameConstraint?.isActive = badgeTitle == nil ? true : false
        badgeTagLabel.textColor = isLeader ? .spForeground3 : .brandColor
        leaderBadge.isHidden = !isLeader || isDeleted
    }

    /// Subtitle should contains `replying to` and `timestamp` information
    func setSubtitle(_ subtitle: String?) {
        subtitleLabel.text = subtitle
    }

    func setDate(_ date: String?) {
        dateLabel.text = date
    }

    func setMoreButton(hidden: Bool) {
        moreButton.isHidden = hidden
    }

    // MARK: - Private

    private func setupUI() {
        addSubviews(deletedMessageLabel,
                    userNameButton,
                    userNameLabel,
                    badgeTagLabel,
                    leaderBadge,
                    moreButton,
                    subtitleLabel,
                    dateLabel)
        configureDeletedLabel()
        configureUserNameLabel()
        setupMoreButton()
        configureLeaderBadge()
        configureBadgeTagLabel()
        configureSubtitleAndDateLabels()
    }

    private func configureDeletedLabel() {
        deletedMessageLabel.backgroundColor = .spBackground0

        deletedMessageLabel.pinEdges(to: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5
        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .foregroundColor: UIColor.spForeground3,
            .font: UIFont.preferred(style: .regularItalic, of: 17.0),
            .paragraphStyle: paragraphStyle
        ]

        deletedMessageLabel.attributedText = NSAttributedString(
            string: NSLocalizedString(
                "This message was deleted.",
                comment: "deleted message"
            ),
            attributes: attributes
        )
    }

    private func configureUserNameLabel() {
        userNameLabel.textColor = .spForeground1
        userNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        userNameLabel.backgroundColor = .spBackground0
        userNameLabel.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -69.0)
        }

        userNameLabel.isUserInteractionEnabled = false

        userNameButton.addTarget(self, action: #selector(userNameTapped), for: .touchUpInside)
        userNameButton.layout {
            $0.top.equal(to: userNameLabel.topAnchor)
            $0.leading.equal(to: userNameLabel.leadingAnchor)
            $0.trailing.equal(to: userNameLabel.trailingAnchor)
            $0.bottom.equal(to: subtitleLabel.bottomAnchor)
        }
    }

    private func setupMoreButton() {
        moreButton.backgroundColor = .spBackground0
        let image = UIImage(spNamed: "menu_icon")
        moreButton.setImage(image, for: .normal)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        moreButton.layout {
            $0.height.equal(to: 44.0)
            $0.width.equal(to: 44.0)
            $0.centerY.equal(to: userNameLabel.centerYAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
    }

    private func configureLeaderBadge() {
        leaderBadge.image = UIImage(spNamed: "leader_badge_icon", for: .light)?.withRenderingMode(.alwaysTemplate)
        leaderBadge.contentMode = .center
        leaderBadge.isHidden = true
        leaderBadge.layout {
            $0.centerY.equal(to: userNameLabel.centerYAnchor)
            $0.leading.equal(to: userNameLabel.trailingAnchor, offsetBy: 12.0)
            $0.width.equal(to: 13.0)
        }
    }

    private func configureBadgeTagLabel() {
        badgeTagLabel.backgroundColor = .spBackground0
        badgeTagLabel.font = .preferred(style: .medium, of: Theme.fontSize)
        badgeTagLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        badgeTagLabel.layout {
            $0.top.equal(to: userNameLabel.bottomAnchor, offsetBy: 6.0)
            $0.leading.equal(to: userNameLabel.leadingAnchor)
        }
    }

    private func configureSubtitleAndDateLabels() {
        subtitleLabel.textColor = .spForeground3
        subtitleLabel.backgroundColor = .spBackground0
        subtitleLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.layout {
            $0.top.equal(to: badgeTagLabel.bottomAnchor, offsetBy: 6.0).priority = .defaultHigh
            subtitleToNameConstraint = $0.top.equal(to: userNameLabel.bottomAnchor, offsetBy: 6.0)
            $0.leading.equal(to: userNameLabel.leadingAnchor)
            $0.trailing.equal(to: dateLabel.leadingAnchor)
        }

        dateLabel.textColor = .spForeground3
        dateLabel.backgroundColor = .spBackground0
        dateLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        dateLabel.isUserInteractionEnabled = false
        dateLabel.layout {
            $0.top.equal(to: subtitleLabel.topAnchor)
            $0.trailing.lessThanOrEqual(to: moreButton.leadingAnchor, offsetBy: 0.0)
        }
    }

    // MARK: - Actions

    @objc
    private func moreTapped() {
        delegate?.moreButtonDidTapped(sender: moreButton)
    }

    @objc
    private func userNameTapped() {
        delegate?.userNameDidTapped()
    }

}

// MARK: - Delegate

protocol UserNameViewDelegate: class {
    func moreButtonDidTapped(sender: UIButton)
    func userNameDidTapped()
}

// MARK: - Theme

private enum Theme {
    static let fontSize: CGFloat = 16.0
}

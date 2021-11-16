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

    private let userNameLabel: BaseLabel = .init()
    private let badgeTagLabel: BaseLabel = .init()
    private let stackview = UIStackView()
    private let subtitleLabel: BaseLabel = .init()
    private let dateLabel: BaseLabel = .init()
    private let leaderBadge: BaseUIImageView = .init()
    private let moreButton: BaseButton = .init()
    private let deletedMessageLabel: BaseLabel = .init()

    private var subtitleToNameConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        applyAccessibility()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        userNameLabel.textColor = .spForeground1
        userNameLabel.backgroundColor = .spBackground0
        moreButton.backgroundColor = .spBackground0
        badgeTagLabel.backgroundColor = .spBackground0
        subtitleLabel.textColor = .spForeground3
        subtitleLabel.backgroundColor = .spBackground0
        dateLabel.textColor = .spForeground3
        dateLabel.backgroundColor = .spBackground0
        deletedMessageLabel.backgroundColor = .spBackground0
    }


    func setDeletedOrReported(isDeleted: Bool, isReported: Bool) {
        let showDeletedLabel = isDeleted || isReported
        deletedMessageLabel.isHidden = !showDeletedLabel
        userNameLabel.isHidden = showDeletedLabel
        dateLabel.isHidden = showDeletedLabel
        subtitleLabel.isHidden = showDeletedLabel
        leaderBadge.isHidden = showDeletedLabel
        moreButton.isHidden = showDeletedLabel
        badgeTagLabel.isHidden = showDeletedLabel
        configureDeletedLabel(isReported: isReported)
    }

    func setUserName(
        _ name: String?,
        badgeTitle: String?,
        isLeader: Bool = false,
        contentType: ContentType,
        isDeleted: Bool,
        isOneLine: Bool = true) {

        leaderBadge.tintColor = .brandColor
        switch contentType {
        case .comment:
            userNameLabel.font = .preferred(style: .bold, of: Theme.fontSize)

        case .reply:
            userNameLabel.font = .preferred(style: .medium, of: Theme.fontSize)
        }

        userNameLabel.text = name
        badgeTagLabel.text = badgeTitle
        
        checkStackViewDirection(isOneLine: isOneLine)
        
        subtitleToNameConstraint?.isActive = badgeTitle == nil ? true : false
        badgeTagLabel.textColor = isLeader ? .spForeground3 : .brandColor
        badgeTagLabel.layer.borderColor = isLeader ? UIColor.spForeground3.cgColor : UIColor.brandColor.cgColor
        leaderBadge.isHidden = !isLeader || isDeleted
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.checkStackViewDirection()
//    }
    
    private func checkStackViewDirection(isOneLine: Bool) {
        stackview.axis = isOneLine ? .horizontal : .vertical
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
                    userNameLabel,
                    badgeTagLabel,
                    leaderBadge,
                    moreButton,
                    subtitleLabel,
                    dateLabel)
        configureUserNameLabel()
        setupMoreButton()
        configureLeaderBadge()
//        configureBadgeTagLabel()
        configureSubtitleAndDateLabels()
        updateColorsAccordingToStyle()
    }

    private func configureDeletedLabel(isReported: Bool = false) {
        deletedMessageLabel.backgroundColor = .spBackground0

        deletedMessageLabel.pinEdges(to: self)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 3.5
        paragraphStyle.updateAlignment()
        
        var attributes: [NSAttributedString.Key: Any]
        attributes = [
            .foregroundColor: UIColor.spForeground3,
            .font: UIFont.preferred(style: .regularItalic, of: 17.0),
            .paragraphStyle: paragraphStyle
        ]

        deletedMessageLabel.attributedText = NSAttributedString(
            string: LocalizationManager.localizedString(key: isReported ? "This message was reported." : "This message was deleted."),
            attributes: attributes
        )
    }

    private func configureUserNameLabel() {
        stackview.addArrangedSubview(userNameLabel)
        stackview.addArrangedSubview(badgeTagLabel)
        stackview.axis = .horizontal
        stackview.alignment = .leading
        stackview.spacing = 4
        
        badgeTagLabel.font = .preferred(style: .medium, of: Theme.labelFontSize)
        badgeTagLabel.layer.borderWidth = 1
        badgeTagLabel.layer.cornerRadius = 3
        badgeTagLabel.insets = UIEdgeInsets(top: 2, left: 4, bottom: 2, right: 4)
        badgeTagLabel.layer.masksToBounds = true
        badgeTagLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        userNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        self.addSubviews(stackview)
        stackview.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -25)
        }

        userNameLabel.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped))
        userNameLabel.addGestureRecognizer(labelTap)
    }

    private func setupMoreButton() {
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
            $0.leading.equal(to: userNameLabel.trailingAnchor, offsetBy: 9.0)
            $0.width.equal(to: 13.0)
        }
    }

//    private func configureBadgeTagLabel() {
//        badgeTagLabel.font = .preferred(style: .medium, of: Theme.fontSize)
//        badgeTagLabel.setContentCompressionResistancePriority(.required, for: .vertical)
//        badgeTagLabel.layout {
////            $0.top.equal(to: userNameLabel.bottomAnchor, offsetBy: 6.0)
////            $0.leading.equal(to: userNameLabel.leadingAnchor)
//            $0.leading.equal(to: userNameLabel.trailingAnchor, offsetBy: 4)
//            $0.centerY.equal(to: userNameLabel.centerYAnchor)
//        }
//    }

    private func configureSubtitleAndDateLabels() {
        subtitleLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.layout {
            $0.top.equal(to: stackview.bottomAnchor, offsetBy: 6.0)
            $0.leading.equal(to: userNameLabel.leadingAnchor)
            $0.trailing.equal(to: dateLabel.leadingAnchor)
        }

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

// MARK: Accessibility

extension UserNameView {
  func applyAccessibility() {
    moreButton.accessibilityTraits = .button
    moreButton.accessibilityLabel = LocalizationManager.localizedString(key: "Options menu")
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
    static let labelFontSize: CGFloat = 12.0
}

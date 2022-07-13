//
//  UserNameView.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 27/09/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal final class UserNameView: OWBaseView {

    enum ContentType {
        case comment, reply
    }

    weak var delegate: UserNameViewDelegate?

    private let userNameLabel: OWBaseLabel = .init()
    private let badgeTagLabel: OWBaseLabel = .init()
    private let nameAndBadgeStackview = UIStackView()
    private let subtitleLabel: OWBaseLabel = .init()
    private let dateLabel: OWBaseLabel = .init()
    private let moreButton: OWBaseButton = .init()
    private let deletedMessageLabel: OWBaseLabel = .init()
    private lazy var subscriberBadgeView: OWUserSubscriberBadgeView = {
        return OWUserSubscriberBadgeView()
    }()

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
        moreButton.isHidden = showDeletedLabel
        badgeTagLabel.isHidden = showDeletedLabel
        subscriberBadgeView.isHidden = showDeletedLabel
        configureDeletedLabel(isReported: isReported)
    }

    func setUserName(
        _ name: String?,
        badgeTitle: String?,
        contentType: ContentType,
        isDeleted: Bool,
        isOneLine: Bool = true) {

        switch contentType {
        case .comment:
            userNameLabel.font = .preferred(style: .bold, of: Theme.fontSize)

        case .reply:
            userNameLabel.font = .preferred(style: .medium, of: Theme.fontSize)
        }

        userNameLabel.text = name
        badgeTagLabel.text = badgeTitle
        
        subtitleToNameConstraint?.isActive = badgeTitle == nil ? true : false
        nameAndBadgeStackview.axis = isOneLine ? .horizontal : .vertical
        badgeTagLabel.isHidden = badgeTitle == nil
        badgeTagLabel.textColor = .brandColor
        badgeTagLabel.layer.borderColor = UIColor.brandColor.cgColor
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

    func configureSubscriberBadgeVM(viewModel: OWUserSubscriberBadgeViewModeling) {
        subscriberBadgeView.configure(with: viewModel)
    }
    
    // MARK: - Private

    private func setupUI() {
        addSubviews(deletedMessageLabel,
                    userNameLabel,
                    badgeTagLabel,
                    moreButton,
                    subtitleLabel,
                    dateLabel)
        configureNameAndBadgeStackView()
        setupMoreButton()
        configureSubtitleAndDateLabels()
        configureSubscriberBadgeView()
        updateColorsAccordingToStyle()
    }

    private func configureDeletedLabel(isReported: Bool = false) {
        deletedMessageLabel.backgroundColor = .spBackground0

        deletedMessageLabel.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

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

    private func configureNameAndBadgeStackView() {
        nameAndBadgeStackview.addArrangedSubview(userNameLabel)
        nameAndBadgeStackview.addArrangedSubview(badgeTagLabel)
        nameAndBadgeStackview.axis = .horizontal
        nameAndBadgeStackview.alignment = .leading
        nameAndBadgeStackview.spacing = Theme.badgeLeadingPadding
        
        badgeTagLabel.font = .preferred(style: .medium, of: Theme.labelFontSize)
        badgeTagLabel.layer.borderWidth = 1
        badgeTagLabel.layer.cornerRadius = 3
        badgeTagLabel.insets = UIEdgeInsets(top: Theme.badgeVerticalInset, left: Theme.badgeHorizontalInset, bottom: Theme.badgeVerticalInset, right: Theme.badgeHorizontalInset)
        badgeTagLabel.layer.masksToBounds = true
        badgeTagLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        userNameLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        self.addSubviews(nameAndBadgeStackview)
        nameAndBadgeStackview.OWSnp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-Theme.usernameTrailingPadding)
        }

        userNameLabel.isUserInteractionEnabled = true
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(userNameTapped))
        userNameLabel.addGestureRecognizer(labelTap)
    }
    
    private func configureSubscriberBadgeView() {
        self.addSubviews(subscriberBadgeView)
        subscriberBadgeView.OWSnp.makeConstraints { make in
            make.top.equalTo(nameAndBadgeStackview)
            make.leading.equalTo(nameAndBadgeStackview.OWSnp.trailing).offset(5.0)
        }
    }

    private func setupMoreButton() {
        let image = UIImage(spNamed: "menu_icon", supportDarkMode: true)
        moreButton.setImage(image, for: .normal)
        moreButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        moreButton.OWSnp.makeConstraints { make in
            make.size.equalTo(44.0)
            make.centerY.equalTo(userNameLabel)
            make.trailing.equalToSuperview()
        }
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
    }

    private func configureSubtitleAndDateLabels() {
        subtitleLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        subtitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        subtitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subtitleLabel.isUserInteractionEnabled = false
        subtitleLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(nameAndBadgeStackview.OWSnp.bottom).offset(Theme.subtitleTopPadding)
            make.leading.equalTo(userNameLabel)
            make.trailing.equalTo(dateLabel.OWSnp.leading)
        }

        dateLabel.font = .preferred(style: .regular, of: Theme.fontSize)
        dateLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        dateLabel.isUserInteractionEnabled = false
        dateLabel.OWSnp.makeConstraints { make in
            make.top.equalTo(subtitleLabel)
            make.trailing.lessThanOrEqualTo(moreButton.OWSnp.leading)
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
    
    static let usernameTrailingPadding: CGFloat = 25.0
    static let badgeLeadingPadding: CGFloat = 4
    static let badgeHorizontalInset: CGFloat = 4
    static let badgeVerticalInset: CGFloat = 2
    static let subtitleTopPadding: CGFloat = 6
}

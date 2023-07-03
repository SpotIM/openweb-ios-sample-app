//
//  SPEmptyConversationActionView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/13/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

struct EmptyActionDataModel {

    typealias Action = (() -> Void)

    let actionMessage: String
    let actionIcon: UIImage
    let actionButtonTitle: String?
    let action: Action?

    init(actionMessage: String, actionIcon: UIImage, actionButtonTitle: String? = nil, action: Action? = nil) {
        self.actionMessage = actionMessage
        self.actionIcon = actionIcon
        self.actionButtonTitle = actionButtonTitle
        self.action = action
    }
}

final class SPEmptyConversationActionView: SPBaseView {

    private let iconView: SPBaseUIImageView = .init()
    let messageLabel: SPBaseLabel = .init()
    private let actionButton: SPBaseButton = .init()
    private let containerView: SPBaseView = .init()
    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI(showingIcon: true)
    }

    init(showingIcon: Bool = true) {
        super.init(frame: .zero)

        setupUI(showingIcon: showingIcon)
    }

    func configure(actionModel: EmptyActionDataModel) {
        action = actionModel.action
        iconView.image = actionModel.actionIcon
        messageLabel.text = actionModel.actionMessage
        if let actionButtonTitle = actionModel.actionButtonTitle {
            actionButton.setTitle(actionButtonTitle, for: .normal)
        } else {
            actionButton.isHidden = true
        }

        updateColorsAccordingToStyle()
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        self.backgroundColor = .spBackground0
        containerView.backgroundColor = .spBackground0
        iconView.backgroundColor = .spBackground0
        messageLabel.backgroundColor = .spBackground0
        messageLabel.textColor = .spForeground3
        actionButton.backgroundColor = .brandColor
    }

    private func setupUI(showingIcon: Bool) {
        addSubview(containerView)
        configureContainerView()
        configureMessageLabel(relativeToIcon: showingIcon)
        if showingIcon {
            configureImageView()
        }
        configureActionButton()
    }

    private func configureContainerView() {
        containerView.addSubviews(iconView, messageLabel, actionButton)
        containerView.OWSnp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview().offset(Theme.horizontalOffset)
            make.trailing.lessThanOrEqualToSuperview().offset(Theme.horizontalOffset)
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
            make.center.equalToSuperview()
        }
    }

    private func configureImageView() {
        iconView.OWSnp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(Theme.imageViewHeight)
            make.width.equalTo(Theme.imageViewWidth)
        }
    }

    private func configureMessageLabel(relativeToIcon: Bool) {
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.preferred(style: .regular, of: Theme.titleFontSize)
        messageLabel.textAlignment = .center
        messageLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if relativeToIcon {
                make.top.equalTo(iconView.OWSnp.bottom).offset(Theme.messageTopBottomOffset)
            } else {
                make.top.equalToSuperview()
            }
            make.bottom.equalTo(actionButton.OWSnp.top)
            make.height.greaterThanOrEqualTo(Theme.messageMinHeight)
        }
    }

    private func configureActionButton() {
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.preferred(style: .medium, of: Theme.actionButtonTitleFontSize)
        actionButton.OWSnp.makeConstraints { make in
            make.height.equalTo(Theme.actionButtonHeight)
            make.centerX.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(Theme.actionButtonMinWidth)
        }
        actionButton.addCornerRadius(Theme.actionButtonCornerRadius)
        actionButton.contentEdgeInsets = UIEdgeInsets(
            top: 0.0,
            left: Theme.actionButtonSideOffset,
            bottom: 0.0,
            right: Theme.actionButtonSideOffset
        )
    }

    @objc
    private func handleAction() {
        action?()
    }
}

private enum Theme {

    static let horizontalOffset: CGFloat = 44.0
    static let titleFontSize: CGFloat = 16.0
    static let actionButtonMinWidth: CGFloat = 137.0
    static let actionButtonHeight: CGFloat = 32.0
    static let actionButtonTitleFontSize: CGFloat = 16.0
    static let messageTopBottomOffset: CGFloat = 27.0
    static let messageMinHeight: CGFloat = 68.0
    static let actionButtonSideOffset: CGFloat = 20.0
    static let actionButtonCornerRadius: CGFloat = 4
    static let imageViewHeight: CGFloat = 50
    static let imageViewWidth: CGFloat = 60
}

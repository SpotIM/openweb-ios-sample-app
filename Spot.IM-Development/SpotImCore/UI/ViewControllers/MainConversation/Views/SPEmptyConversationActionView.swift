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

final class SPEmptyConversationActionView: BaseView {

    private let iconView: BaseUIImageView = .init()
    private let messageLabel: BaseLabel = .init()
    private let actionButton: BaseButton = .init()
    private let containerView: BaseView = .init()
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
        containerView.layout {
            $0.leading.greaterThanOrEqual(to: leadingAnchor, offsetBy: Theme.containerLeadingTrailingOffset)
            $0.trailing.lessThanOrEqual(to: trailingAnchor, offsetBy: -Theme.containerLeadingTrailingOffset)
            $0.top.greaterThanOrEqual(to: topAnchor)
            $0.bottom.lessThanOrEqual(to: bottomAnchor)
            $0.centerX.equal(to: centerXAnchor)
            $0.centerY.equal(to: centerYAnchor)
        }
    }
    
    private func configureImageView() {
        iconView.layout {
            $0.centerX.equal(to: containerView.centerXAnchor)
            $0.top.equal(to: containerView.topAnchor)
            $0.height.equal(to: Theme.imageViewHeight)
            $0.width.equal(to: Theme.imageViewWidth)
        }
    }
    
    private func configureMessageLabel(relativeToIcon: Bool) {
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.preferred(style: .regular, of: Theme.titleFontSize)
        messageLabel.textAlignment = .center
        messageLabel.layout {
            $0.leading.equal(to: containerView.leadingAnchor)
            $0.trailing.equal(to: containerView.trailingAnchor)
            if relativeToIcon {
                $0.top.equal(to: iconView.bottomAnchor, offsetBy: Theme.messageTopBottomOffset)
            } else {
                $0.top.equal(to: containerView.topAnchor)
            }
            $0.bottom.equal(to: actionButton.topAnchor)
            $0.height.greaterThanOrEqual(to: Theme.messageMinHeight)
        }
    }
    
    private func configureActionButton() {
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.font = UIFont.preferred(style: .medium, of: Theme.actionButtonTitleFontSize)
        
        actionButton.layout {
            $0.height.equal(to: Theme.actionButtonHeight)
            $0.centerX.equal(to: containerView.centerXAnchor)
            $0.bottom.equal(to: containerView.bottomAnchor)
            $0.width.greaterThanOrEqual(to: Theme.actionButtonMinWidth)
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
    
    static let containerLeadingTrailingOffset: CGFloat = 44.0
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

//
//  SPMainConversationFooterView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPMainConversationFooterViewDelegate: AnyObject {
    
    func labelContainerDidTap(_ foorterView: SPMainConversationFooterView)
    
    func userAvatarDidTap(_ foorterView: SPMainConversationFooterView)
    
}

final class SPMainConversationFooterView: OWBaseView {
    private let cache = NSCache<NSString, UIImage>()
    private let callToActionLabel: OWBaseLabel = .init()
    private let userAvatarView: SPAvatarView = .init()
    private let labelContainer: OWBaseView = .init()
    
    private lazy var separatorView: OWBaseView = .init()
    private lazy var bannerContainerView: OWBaseView = .init()
    
    private var bannerView: UIView?
    private var bannerContainerHeight: NSLayoutConstraint?
    
    private var readOnlyLabel: OWBaseLabel?

    internal weak var delegate: SPMainConversationFooterViewDelegate?
    
    internal var dropsShadow: Bool = false {
        didSet { showSeparatorIfNeeded() }
    }
    
    internal var showsSeparator: Bool = true {
        didSet { separatorView.isHidden = !showsSeparator }
    }
    
    override var bounds: CGRect {
        didSet {
            dropShadowIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        setup()
    }
    
    func handleUICustomizations(customUIDelegate: CustomUIDelegate, isPreConversation: Bool) {
        customUIDelegate.customizeSayControl(labelContainer: labelContainer, label: callToActionLabel, isPreConversation: isPreConversation)
        if (!isPreConversation) {
            customUIDelegate.customizeConversationFooter(view: self)
        }
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        labelContainer.backgroundColor = .spBackground1
        labelContainer.layer.borderColor = UIColor.spBorder.cgColor
        callToActionLabel.textColor = .spForeground2
        separatorView.backgroundColor = .spSeparator2
        dropsShadow = !SPUserInterfaceStyle.isDarkMode
        self.readOnlyLabel?.textColor = .spForeground3
    }
    
    /// Updates user's avatar, `nil` will set default placeholder
    func updateAvatar(_ avatarUrl: URL?) {
        userAvatarView.updateAvatar(avatarUrl: avatarUrl)
    }
    
    /// Updates user's online status, `nil` will hide status view
    func updateOnlineStatus(_ status: OnlineStatus) {
        userAvatarView.updateOnlineStatus(status)
    }

    func setCallToAction(text: String) {
        callToActionLabel.text = text
    }
    
    private func setup() {
        addSubviews(bannerContainerView, labelContainer, userAvatarView, separatorView)
        
        labelContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelContainerTap)))
        labelContainer.isUserInteractionEnabled = true
        
        setupUserAvatarView()
        setupCallToActionLabel()
        
        configureSeparatorView()
        setupBannerView()
    }
    
    func setReadOnlyMode(isPreConversation: Bool = false) {
        guard readOnlyLabel == nil else { return }
        labelContainer.isUserInteractionEnabled = false
        labelContainer.isHidden = true
        userAvatarView.isHidden = true
        
        readOnlyLabel = OWBaseLabel()
        setupReadOnlyLabel(isPreConversation: isPreConversation)
    }
    
    func setupReadOnlyLabel(isPreConversation: Bool) {
        guard let readOnlyLabel = self.readOnlyLabel else { return }
        addSubview(readOnlyLabel)
        
        readOnlyLabel.font = UIFont.preferred(style: .regular, of: Theme.fontSize)
        readOnlyLabel.textColor = .spForeground3
        readOnlyLabel.text = LocalizationManager.localizedString(key: "Commenting on this article has ended")
        
        readOnlyLabel.layout {
            $0.centerY.equal(to: labelContainer.centerYAnchor)
            if (isPreConversation) {
                $0.leading.equal(to: self.leadingAnchor, offsetBy: Theme.readOnlyLabelLeading)
            } else {
                $0.centerX.equal(to: self.centerXAnchor)
            }
        }
    }
    
    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerContainerView.addSubview(bannerView)
        bannerView.layout {
            $0.height.equal(to: height)
            $0.centerX.equal(to: bannerContainerView.centerXAnchor)
            $0.bottom.equal(to: bannerContainerView.bottomAnchor)
        }
        bannerContainerHeight?.constant = height + 16.0
    }
    
    private func setupBannerView() {
        bannerContainerView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            bannerContainerHeight = $0.height.equal(to: 0.0)
        }
    }
    
    private func setupCallToActionLabel() {
        labelContainer.backgroundColor = .spBackground1
        labelContainer.layout {
            $0.top.equal(to: bannerContainerView.bottomAnchor, offsetBy: 16.0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -15.0)
            $0.leading.equal(to: userAvatarView.trailingAnchor, offsetBy: 12.0)
            $0.height.equal(to: 48.0)
        }
        labelContainer.layer.borderColor = UIColor.spBorder.cgColor
        labelContainer.layer.borderWidth = 1.0
        labelContainer.addCornerRadius(6.0)
        labelContainer.addSubview(callToActionLabel)
        callToActionLabel.textColor = .spForeground2
        callToActionLabel.font = UIFont.preferred(style: .regular, of: Theme.fontSize)
        callToActionLabel.text = LocalizationManager.localizedString(key: "What do you think?")
        
        callToActionLabel.layout {
            $0.centerY.equal(to: labelContainer.centerYAnchor)
            $0.leading.equal(to: labelContainer.leadingAnchor, offsetBy: Theme.callToActionLeading)
            $0.height.equal(to: Theme.callToActionHeight)
        }
    }
    
    private func setupUserAvatarView() {
        userAvatarView.delegate = self
        userAvatarView.backgroundColor = .clear
        userAvatarView.layout {
            $0.centerY.equal(to: labelContainer.centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: Theme.userAvatarLeading)
            $0.height.equal(to: Theme.userAvatarSize)
            $0.width.equal(to: Theme.userAvatarSize)
        }
    }

    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.layout {
            $0.top.equal(to: topAnchor)
            $0.leading.equal(to: leadingAnchor)
            $0.trailing.equal(to: trailingAnchor)
            $0.height.equal(to: Theme.separatorHeight)
        }
    }
    
    private func dropShadowIfNeeded() {
        guard dropsShadow else {
            layer.shadowPath = nil
            return
        }
        let shadowRect = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height / 2)
        let shadowPath = UIBezierPath(rect: shadowRect)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        layer.shadowOpacity = 0.08
        layer.shadowPath = shadowPath.cgPath
    }
    
    private func dropContainerShadowIfNeeded() {
        guard dropsShadow, !SPUserInterfaceStyle.isDarkMode else {
            labelContainer.layer.shadowPath = nil
            return
        }
        
        let containerShadowRect = CGRect(
            x: 0.0,
            y: 0.0,
            width: labelContainer.bounds.width,
            height: labelContainer.bounds.height)
        let containerShadowPath = UIBezierPath(rect: containerShadowRect)
        labelContainer.layer.masksToBounds = false
        labelContainer.layer.shadowColor = UIColor.black.cgColor
        labelContainer.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        labelContainer.layer.shadowRadius = 5.0
        labelContainer.layer.shadowOpacity = 0.2
        labelContainer.layer.shadowPath = containerShadowPath.cgPath
    }

    private func showSeparatorIfNeeded() {
        separatorView.isHidden = dropsShadow
    }
    
    @objc
    private func labelContainerTap() {
        delegate?.labelContainerDidTap(self)
    }
}

extension SPMainConversationFooterView: AvatarViewDelegate {
    func avatarDidTapped() {
        delegate?.userAvatarDidTap(self)
    }
}

// MARK: - Theme

private enum Theme {

    static let separatorHeight: CGFloat = 1
    static let userAvatarSize: CGFloat = 40
    static let userAvatarLeading: CGFloat = 15
    static let callToActionLeading: CGFloat = 12
    static let callToActionHeight: CGFloat = 48
    static let readOnlyLabelLeading: CGFloat = 15
    static let fontSize: CGFloat = 16
}

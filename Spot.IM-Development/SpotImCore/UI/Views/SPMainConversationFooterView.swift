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
    let userAvatarView: SPAvatarView = .init()
    private let labelContainer: OWBaseView = .init()
    
    private lazy var separatorView: OWBaseView = .init()
    private lazy var bannerContainerView: OWBaseView = .init()
    
    private var bannerView: UIView?
    private var bannerContainerHeight: OWConstraint?
    
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
    
    func handleUICustomizations(customUIDelegate: OWCustomUIDelegate, isPreConversation: Bool) {
        customUIDelegate.customizeSayControl(labelContainer: labelContainer, label: callToActionLabel, isPreConversation: isPreConversation)
        if (!isPreConversation) {
            customUIDelegate.customizeConversationFooter(view: self)
        }
        
        if let readOnlyLabel = readOnlyLabel {
            customUIDelegate.customizeReadOnlyLabel(label: readOnlyLabel)
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
        
        readOnlyLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(labelContainer)
            if (isPreConversation) {
                make.leading.equalToSuperview().offset(Theme.readOnlyLabelLeading)
            } else {
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func updateBannerView(_ bannerView: UIView, height: CGFloat) {
        self.bannerView?.removeFromSuperview()
        self.bannerView = bannerView
        bannerContainerView.addSubview(bannerView)
        bannerView.OWSnp.makeConstraints { make in
            make.height.equalTo(height)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        bannerContainerHeight?.deactivate()
        bannerContainerView.OWSnp.updateConstraints { make in
            bannerContainerHeight = make.height.equalTo(height + 16.0).constraint
        }
    }
    
    private func setupBannerView() {
        bannerContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            bannerContainerHeight = make.height.equalTo(0.0).constraint
        }
    }
    
    private func setupCallToActionLabel() {
        labelContainer.backgroundColor = .spBackground1
        labelContainer.OWSnp.makeConstraints { make in
            make.top.equalTo(bannerContainerView.OWSnp.bottom).offset(16.0)
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(12.0)
            make.height.equalTo(48.0)
        }
        labelContainer.layer.borderColor = UIColor.spBorder.cgColor
        labelContainer.layer.borderWidth = 1.0
        labelContainer.addCornerRadius(6.0)
        labelContainer.addSubview(callToActionLabel)
        callToActionLabel.textColor = .spForeground2
        callToActionLabel.font = UIFont.preferred(style: .regular, of: Theme.fontSize)
        callToActionLabel.text = LocalizationManager.localizedString(key: "What do you think?")
        
        callToActionLabel.OWSnp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(Theme.callToActionLeading)
            make.height.equalTo(Theme.callToActionHeight)
        }
    }
    
    private func setupUserAvatarView() {
        userAvatarView.delegate = self
        userAvatarView.backgroundColor = .clear
        userAvatarView.OWSnp.makeConstraints { make in
            make.centerY.equalTo(labelContainer)
            make.leading.equalToSuperview().offset(Theme.userAvatarLeading)
            make.size.equalTo(Theme.userAvatarSize)
        }
    }

    private func configureSeparatorView() {
        separatorView.backgroundColor = .spSeparator2
        separatorView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
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

extension SPMainConversationFooterView: OWAvatarViewDelegate {
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

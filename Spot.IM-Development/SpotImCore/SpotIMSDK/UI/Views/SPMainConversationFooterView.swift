//
//  SPMainConversationFooterView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

internal protocol SPMainConversationFooterViewDelegate: class {
    
    func footerViewDidTap(_ foorterView: SPMainConversationFooterView)
    
}

final class SPMainConversationFooterView: BaseView {
    
    private let cache = NSCache<NSString, UIImage>()
    private let callToActionLabel: UILabel = .init()
    private let userAvatarView: SPAvatarView = .init()
    private let labelContainer: UIView = .init()
    private let button: UIButton = .init(type: .system)

    internal weak var delegate: SPMainConversationFooterViewDelegate?
    internal var dropsShadow: Bool = false

    override var bounds: CGRect {
        didSet {
            dropShadowIfNeeded()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = false
        backgroundColor = .white
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        dropContainerShadowIfNeeded()
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
        addSubviews(labelContainer, userAvatarView, button)
        button.addTarget(self, action: #selector(tap), for: .touchUpInside)
        button.pinEdges(to: self)
        setupUserAvatarImageView()
        setupCallToActionLabel()
    }
    
    private func setupCallToActionLabel() {
        labelContainer.backgroundColor = .white
        labelContainer.layout {
            $0.top.equal(to: topAnchor, offsetBy: 16.0)
            $0.trailing.equal(to: trailingAnchor, offsetBy: -15.0)
            $0.leading.equal(to: userAvatarView.trailingAnchor, offsetBy: 12.0)
            $0.height.equal(to: 48.0)
        }
        labelContainer.layer.borderColor = UIColor.lightBlueGrey.cgColor
        labelContainer.layer.borderWidth = 1.0
        labelContainer.addCornerRadius(4.0)
        labelContainer.addSubview(callToActionLabel)

        callToActionLabel.textColor = .coolGrey
        callToActionLabel.backgroundColor = .white
        callToActionLabel.font = UIFont.roboto(style: .regular, of: 16.0)
        callToActionLabel.text = NSLocalizedString("What do you think?",
                                                   comment: "Conversation footer call to action placeholder")
        
        callToActionLabel.layout {
            $0.centerY.equal(to: labelContainer.centerYAnchor)
            $0.leading.equal(to: labelContainer.leadingAnchor, offsetBy: 12.0)
            $0.height.equal(to: 48.0)
        }
    }
    
    private func setupUserAvatarImageView() {
        userAvatarView.backgroundColor = .white
        userAvatarView.layout {
            $0.centerY.equal(to: labelContainer.centerYAnchor)
            $0.leading.equal(to: leadingAnchor, offsetBy: 15.0)
            $0.height.equal(to: 40.0)
            $0.width.equal(to: 40.0)
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
        guard !dropsShadow else {
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
    
    @objc
    private func tap() {
        delegate?.footerViewDidTap(self)
    }
}

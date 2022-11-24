//
//  SPMainConversationFooterView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPMainConversationFooterView: OWBaseView {
    fileprivate struct Metrics {
        static let identifier = "main_conversation_footer_id"
        static let commentCreationEntryIdentifier = "main_conversation_footer_comment_creation_entry_id"
        static let readOnlyLabelIdentifier = "main_conversation_footer_readOnly_label_id"
    }
    
    let commentCreationEntryView: OWCommentCreationEntryView = .init()
    
    private lazy var separatorView: OWBaseView = .init()
    private lazy var bannerContainerView: OWBaseView = .init()
    
    private var bannerView: UIView?
    private var bannerContainerHeight: OWConstraint?
    
    private var readOnlyLabel: OWBaseLabel?
    
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
        setupUI()
        updateColorsAccordingToStyle()
        setupAccessibilityIdentifiers()
    }
    
    private func setupAccessibilityIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
        commentCreationEntryView.accessibilityIdentifier = Metrics.commentCreationEntryIdentifier
        readOnlyLabel?.accessibilityIdentifier = Metrics.readOnlyLabelIdentifier
    }
    
    func handleUICustomizations(customUIDelegate: OWCustomUIDelegate, isPreConversation: Bool) {
        
        commentCreationEntryView.handleUICustomizations(customUIDelegate: customUIDelegate, isPreConversation: isPreConversation)

        if (!isPreConversation) {
            customUIDelegate.customizeView(.footer(view: self), source: .conversation)
        }
        
        if let readOnlyLabel = readOnlyLabel {
            customUIDelegate.customizeView(.readOnlyLabel(label: readOnlyLabel), source: .conversation)
        }
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
        commentCreationEntryView.updateColorsAccordingToStyle()
        separatorView.backgroundColor = .spSeparator2
        dropsShadow = !SPUserInterfaceStyle.isDarkMode
        self.readOnlyLabel?.textColor = .spForeground3
    }
    
    private func setupUI() {
        addSubview(bannerContainerView)
        bannerContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            bannerContainerHeight = make.height.equalTo(0.0).constraint
        }
        
        addSubview(separatorView)
        separatorView.backgroundColor = .spSeparator2
        separatorView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(Theme.separatorHeight)
        }
        
        addSubview(commentCreationEntryView)
        commentCreationEntryView.OWSnp.makeConstraints { make in
            make.top.equalTo(bannerContainerView.OWSnp.bottom).offset(16.0)
            make.trailing.equalToSuperview().offset(-15)
            make.leading.equalToSuperview().offset(15.0)
            make.height.equalTo(48.0)
        }
    }
    
    func setReadOnlyMode(isPreConversation: Bool = false) {
        guard readOnlyLabel == nil else { return }
        commentCreationEntryView.isUserInteractionEnabled = false
        commentCreationEntryView.isHidden = true
      
        readOnlyLabel = OWBaseLabel()
        setupReadOnlyLabel(isPreConversation: isPreConversation)
    }
    
    func setupReadOnlyLabel(isPreConversation: Bool) {
        guard let readOnlyLabel = self.readOnlyLabel else { return }
        addSubview(readOnlyLabel)
        setupAccessibilityIdentifiers()
        readOnlyLabel.font = UIFont.preferred(style: .regular, of: Theme.fontSize)
        readOnlyLabel.textColor = .spForeground3
        readOnlyLabel.text = LocalizationManager.localizedString(key: "Commenting on this article has ended")
        
        readOnlyLabel.OWSnp.makeConstraints { make in
            make.centerY.equalTo(commentCreationEntryView)
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
        setupAccessibilityIdentifiers()
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

    private func showSeparatorIfNeeded() {
        separatorView.isHidden = dropsShadow
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

//
//  SPAvatarView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

enum OnlineStatus {
    
    case online
    case offline
    
}

protocol AvatarViewDelegate: class {
    
    func avatarDidTapped()
    
}

final class SPAvatarView: BaseView {

    weak var delegate: AvatarViewDelegate?
    
    private let avatarImageView: BaseUIImageView = .init()
    private let onlineIndicatorView: BaseView = .init()
    private let avatarButton: BaseButton = .init()

    private var defaultAvatar: UIImage? { UIImage(spNamed: "defaultAvatar", supportDarkMode: true) }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        applyAccessibility()
    }
    
    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarImageView.makeViewRound()
        onlineIndicatorView.makeViewRound()
    }
    
    private func setup() {
        addSubviews(avatarButton, avatarImageView, onlineIndicatorView)
        setupAvatarButton()
        setupAvatarImageView()
        setupOnlineIndicatorView()
    }
    
    private func setupAvatarButton() {
        avatarButton.addTarget(self, action: #selector(avatarTapped), for: .touchUpInside)
        avatarButton.pinEdges(to: self)
    }
    
    private func setupAvatarImageView() {
        avatarImageView.backgroundColor = .spAvatarBG
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.pinEdges(to: self)
    }
    
    private func setupOnlineIndicatorView() {
        onlineIndicatorView.backgroundColor = .mediumGreen
        onlineIndicatorView.layer.borderWidth = 2.0
        onlineIndicatorView.layer.borderColor = UIColor.spBackground0.cgColor
        onlineIndicatorView.layer.shouldRasterize = true
        onlineIndicatorView.layer.rasterizationScale = UIScreen.main.scale
        onlineIndicatorView.layout {
            $0.height.equal(to: 11.0)
            $0.width.equal(to: 11.0)
            $0.bottom.equal(to: bottomAnchor)
            $0.trailing.equal(to: trailingAnchor)
        }
    }
    
    /// Updates user's avatar, `nil` will set default placeholder
    func updateAvatar(avatarUrl: URL?) {
        if avatarUrl == nil {
            setAvatarOrDefault(image: nil)
        } else {
            avatarImageView.setImage(with: avatarUrl) { [weak self] (image, _) in
                self?.setAvatarOrDefault(image: image)
            }
        }
    }
    
    /// Updates user's avatar, `nil` will set default placeholder
    func updateAvatar(image: UIImage?) {
        setAvatarOrDefault(image: image)
    }
    
    /// Updates user's online status, `nil` will hide status view
    func updateOnlineStatus(_ status: OnlineStatus) {
        onlineIndicatorView.backgroundColor = .mediumGreen
        switch status {
        case .online:
            onlineIndicatorView.isHidden = false
        
        case .offline:
            onlineIndicatorView.isHidden = true
        }
    }

    /// Sets the image to the avatar image view, adds rasterization thereafter.
    /// If the image is nil, tries to set default image.
    /// - Parameter image: Suggested avatar image.
    private func setAvatarOrDefault(image: UIImage?) {
        avatarImageView.backgroundColor = image == nil ? .spAvatarBG : .spBackground0
        avatarImageView.image = image ?? defaultAvatar
        avatarImageView.layer.shouldRasterize = true
        avatarImageView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @objc
    private func avatarTapped() {
        delegate?.avatarDidTapped()
    }
}

// MARK: Accessibility

extension SPAvatarView {
  func applyAccessibility() {
    avatarButton.accessibilityTraits = .image
    avatarButton.accessibilityLabel = LocalizationManager.localizedString(key: "Profile image")
  }
}

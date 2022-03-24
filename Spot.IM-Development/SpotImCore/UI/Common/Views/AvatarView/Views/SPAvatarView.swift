//
//  SPAvatarView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/26/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

enum OWOnlineStatus {
    case online
    case offline
}

protocol OWAvatarViewDelegate: AnyObject {
    func avatarDidTapped()
}

final class SPAvatarView: OWBaseView {

    weak var delegate: OWAvatarViewDelegate?
    
    private let avatarImageView: OWBaseUIImageView = .init()
    private let onlineIndicatorView: OWBaseView = .init()
    private let avatarButton: OWBaseButton = .init()

    private var defaultAvatar: UIImage? { UIImage(spNamed: "defaultAvatar", supportDarkMode: true) }
    
    fileprivate var viewModel: OWAvatarViewModel!
    fileprivate var disposeBag: DisposeBag!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        applyAccessibility()
    }
    
    func configure(with viewModel: OWAvatarViewModel) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        configureViews()
    }
    
    func configureViews() {
        viewModel.outputs.showOnlineIndicator
            .map { !$0 } // Reverse
            .bind(to: onlineIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.outputs.imageUrl
            .subscribe(onNext: { [weak self] url in
                self?.updateAvatar(avatarUrl: url)
            })
            .disposed(by: disposeBag)
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
        avatarButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupAvatarImageView() {
        avatarImageView.backgroundColor = .spAvatarBG
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupOnlineIndicatorView() {
        onlineIndicatorView.backgroundColor = .mediumGreen
        onlineIndicatorView.layer.borderWidth = 2.0
        onlineIndicatorView.layer.borderColor = UIColor.spBackground0.cgColor
        onlineIndicatorView.layer.shouldRasterize = true
        onlineIndicatorView.isHidden = true
        onlineIndicatorView.layer.rasterizationScale = UIScreen.main.scale
        onlineIndicatorView.OWSnp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.size.equalTo(11.0)
        }
    }
    
    /// Updates user's avatar, `nil` will set default placeholder
    private func updateAvatar(avatarUrl: URL?) {
        if avatarUrl == nil {
            setAvatarOrDefault(image: nil)
        } else {
            avatarImageView.setImage(with: avatarUrl) { [weak self] (image, _) in
                self?.setAvatarOrDefault(image: image)
            }
        }
    }
    
//    /// Updates user's avatar, `nil` will set default placeholder
//    private func updateAvatar(image: UIImage?) {
//        setAvatarOrDefault(image: image)
//    }

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

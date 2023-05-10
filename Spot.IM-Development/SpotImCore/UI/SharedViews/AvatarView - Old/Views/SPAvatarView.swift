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
    fileprivate struct Metrics {
        static let identifier = "user_avatar_view_id"
        static let avatarImageIdentifier = "avatar_image_id"
        static let avatarButtonIdentifier = "avatar_button_id"
        static let onlineIndicatorIdentifier = "online_indicator_id"
    }

    weak var delegate: OWAvatarViewDelegate?

    private let avatarImageView: OWBaseUIImageView = .init()
    private let onlineIndicatorView: OWBaseView = .init()
    private let avatarButton: OWBaseButton = .init()

    fileprivate lazy var defaultAvatar: UIImage = {
        let image = UIImage(spNamed: "defaultAvatar", supportDarkMode: true)!
        return image
    }()

    fileprivate var viewModel: SPAvatarViewModeling!
    fileprivate var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        applyAccessibility()
    }

    func configure(with viewModel: SPAvatarViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    func setupObservers() {
        viewModel.outputs.showOnlineIndicator
            .map { !$0 } // Reverse
            .bind(to: onlineIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.imageType
            .subscribe(onNext: { [weak self] avatarImageType in
                self?.updateAvatar(avatarImageType: avatarImageType)
            })
            .disposed(by: disposeBag)

        avatarButton.rx.tap.bind(to: viewModel.inputs.tapAvatar)
            .disposed(by: disposeBag)
    }

    // Handle dark mode \ light mode change
    func updateColorsAccordingToStyle() {
        backgroundColor = .spBackground0
    }

    func prepareForReuse() {
        updateAvatar(avatarImageType: .defaultImage)
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
        updateAvatar(avatarImageType: .defaultImage)
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
    private func updateAvatar(avatarImageType: OWImageType) {
        switch avatarImageType {
        case .defaultImage:
            setAvatarOrDefault(image: nil)
        case .custom(let url):
            avatarImageView.setImage(with: url) { [weak self] (image, _) in
                self?.setAvatarOrDefault(image: image)
            }
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
        // self.accessibilityIdentifier = Metrics.identifier
        avatarImageView.accessibilityIdentifier = Metrics.avatarImageIdentifier
        avatarButton.accessibilityIdentifier = Metrics.avatarButtonIdentifier
        onlineIndicatorView.accessibilityIdentifier = Metrics.onlineIndicatorIdentifier

        avatarButton.accessibilityTraits = .image
        avatarButton.accessibilityLabel = LocalizationManager.localizedString(key: "Profile image")
    }
}

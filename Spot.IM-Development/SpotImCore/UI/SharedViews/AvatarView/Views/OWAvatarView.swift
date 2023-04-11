//
//  OWAvatarView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 11/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

final class OWAvatarView: UIView {
    fileprivate struct Metrics {
        static let identifier = "user_avatar_view_id"
        static let avatarImageIdentifier = "avatar_image_id"
        static let avatarButtonIdentifier = "avatar_button_id"
        static let onlineIndicatorIdentifier = "online_indicator_id"
    }

    weak var delegate: OWAvatarViewDelegate? // TODO: delete

    fileprivate lazy var avatarButton: UIButton = {
        return UIButton()
    }()
    fileprivate lazy var avatarImageView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFill)
    }()
    fileprivate lazy var onlineIndicatorView: UIView = {
        let view = UIView()
            .backgroundColor(.mediumGreen) // TODO: color
            .border(width: 2, color: .white) // TODO: as backgroundColor!
            .isHidden(true)
        return view
    }()

//        onlineIndicatorView.layer.shouldRasterize = true // TODO: ?
//        onlineIndicatorView.layer.rasterizationScale = UIScreen.main.scale // TODO: ?

    fileprivate lazy var defaultAvatar: UIImage = {
        let image = UIImage(spNamed: "defaultAvatar", supportDarkMode: true)!
        return image
    }()

    fileprivate var viewModel: OWAvatarViewModeling!
    fileprivate var disposeBag: DisposeBag!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: OWAvatarViewModeling) {
        self.viewModel = viewModel
        disposeBag = DisposeBag()
        setupObservers()
    }

    func prepareForReuse() {
        updateAvatar(avatarImageType: .defaultImage)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.makeViewRound()
        onlineIndicatorView.makeViewRound()
    }
}

fileprivate extension OWAvatarView {
    private func setupUI() {
        addSubview(avatarButton)
        avatarButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(avatarImageView)
        avatarImageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(onlineIndicatorView)
        onlineIndicatorView.OWSnp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview()
            make.size.equalTo(11.0) // TODO: metrics + real size
        }
    }

    func setupObservers() {
        viewModel.outputs.showOnlineIndicator
            .map { !$0 }
            .bind(to: onlineIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.imageType
            .subscribe(onNext: { [weak self] avatarImageType in
                self?.updateAvatar(avatarImageType: avatarImageType)
            })
            .disposed(by: disposeBag)

        avatarButton.rx.tap
            .bind(to: viewModel.inputs.tapAvatar)
            .disposed(by: disposeBag)
    }

    func updateAvatar(avatarImageType: OWImageType) {
        switch avatarImageType {
        case .defaultImage:
            setAvatarOrDefault(image: defaultAvatar)
        case .custom(let url):
            avatarImageView.setImage(with: url) { [weak self] (image, _) in
                guard let self = self else { return }
                self.setAvatarOrDefault(image: image ?? self.defaultAvatar)
            }
        }
    }

    func setAvatarOrDefault(image: UIImage) {
        avatarImageView.image = image
        // TODO: what this is for ?
//        avatarImageView.layer.shouldRasterize = true
//        avatarImageView.layer.rasterizationScale = UIScreen.main.scale
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        avatarImageView.accessibilityIdentifier = Metrics.avatarImageIdentifier
        avatarButton.accessibilityIdentifier = Metrics.avatarButtonIdentifier
        onlineIndicatorView.accessibilityIdentifier = Metrics.onlineIndicatorIdentifier

        avatarButton.accessibilityTraits = .image
        avatarButton.accessibilityLabel = LocalizationManager.localizedString(key: "Profile image")
    }
}

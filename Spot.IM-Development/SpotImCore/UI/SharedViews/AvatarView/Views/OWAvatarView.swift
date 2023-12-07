//
//  OWAvatarView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 11/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

class OWAvatarView: UIView {
    fileprivate struct Metrics {
        static let identifier = "user_avatar_view_id"
        static let avatarImageIdentifier = "avatar_image_id"
        static let avatarButtonIdentifier = "avatar_button_id"
        static let onlineIndicatorIdentifier = "online_indicator_id"
        static let onlineGreenIndicatorIdentifier = "online_green_indicator_id"

        static let onlineIndicatorSize: CGFloat = 10
        static let innerIndicatorSize: CGFloat = 8
        static let onlineIndicatorBlurStyle: String = "CIGaussianBlur"
        static let onlineIndicatorBlurRadius: CGFloat = 2

        static let lightDefaultAvatar: UIImage? = UIImage(spNamed: "defaultAvatar", supportDarkMode: false)
        static let darkDefaultAvatar: UIImage? = UIImage(spNamed: "defaultAvatar-dark", supportDarkMode: false)

        static func defaultAvatar(style: OWThemeStyle) -> UIImage? {
            switch style {
            case .dark:
                return darkDefaultAvatar
            case .light:
                return lightDefaultAvatar
            }
        }
    }

    fileprivate lazy var avatarButton: UIButton = {
        return UIButton()
    }()

    fileprivate lazy var avatarImageView: UIImageView = {
        return UIImageView()
            .contentMode(.scaleAspectFill)
    }()

    fileprivate lazy var onlineGreenView = {
        UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .green, themeStyle: .light))
            .corner(radius: Metrics.innerIndicatorSize / 2)
    }()

    fileprivate lazy var onlineIndicatorView: UIView = {
        let view = UIView()
            .corner(radius: Metrics.onlineIndicatorSize / 2)
            .isHidden(true)
        if let blurFilter = CIFilter(name: Metrics.onlineIndicatorBlurStyle,
                                     parameters: [kCIInputRadiusKey: Metrics.onlineIndicatorBlurRadius]) {
            view.layer.backgroundFilters = [blurFilter]
        }

        view.addSubview(onlineGreenView)
        onlineGreenView.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.innerIndicatorSize)
            make.center.equalToSuperview()
        }

        return view
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
        updateAvatar(avatarImageType: .defaultImage, style: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Because avatar image size can be changed, we need to re-set corner radius
        avatarImageView.makeViewRound()
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
            make.size.equalTo(Metrics.onlineIndicatorSize)
        }
    }

    func setupObservers() {
        viewModel.outputs.shouldShowOnlineIndicator
            .map { !$0 }
            .bind(to: onlineIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)

        Observable.combineLatest(
            viewModel.outputs.imageType,
            OWSharedServicesProvider.shared.themeStyleService().style
        )
            .subscribe(onNext: { [weak self] avatarImageType, style in
                self?.updateAvatar(avatarImageType: avatarImageType, style: style)
            })
            .disposed(by: disposeBag)

        avatarButton.rx.tap
            .bind(to: viewModel.inputs.tapAvatar)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.onlineIndicatorView.backgroundColor = OWColorPalette.shared.color(type: .borderColor3, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }

    func updateAvatar(avatarImageType: OWImageType, style: OWThemeStyle) {
        switch avatarImageType {
        case .defaultImage:
            avatarImageView.image = Metrics.defaultAvatar(style: style)
        case .custom(let url):
            avatarImageView.setImage(with: url) { [weak self] (image, _) in
                guard let self = self else { return }
                self.avatarImageView.image = image ?? Metrics.defaultAvatar(style: style)
            }
        }
    }

    func applyAccessibility() {
        // self.accessibilityIdentifier = Metrics.identifier
        avatarImageView.accessibilityIdentifier = Metrics.avatarImageIdentifier
        avatarButton.accessibilityIdentifier = Metrics.avatarButtonIdentifier
        onlineIndicatorView.accessibilityIdentifier = Metrics.onlineIndicatorIdentifier
        onlineGreenView.accessibilityIdentifier = Metrics.onlineGreenIndicatorIdentifier

        avatarButton.accessibilityTraits = .image
        avatarButton.accessibilityLabel = OWLocalizationManager.shared.localizedString(key: "ProfileImage")
    }
}

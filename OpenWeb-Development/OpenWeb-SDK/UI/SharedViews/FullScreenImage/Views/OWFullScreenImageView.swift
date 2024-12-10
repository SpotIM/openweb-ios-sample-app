//
//  OWFullScreenImageView.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 14/12/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class OWFullScreenImageView: UIView, OWThemeStyleInjectorProtocol {
    private struct Metrics {
        static let identifier = "full_screen_image_view_id"
        static let backgroundAlpha = 0.85
        static let closeButtonSize: CGFloat = 40
        static let closeButtonIdentidier = "full_screen_image_close_button_id"
        static let closeCrossIcon = "closeCrossIcon"
        static let closeButtonPadding: CGFloat = 8
        static let fadeAnimationDuration = 0.3
    }

    private var viewModel: OWFullScreenImageViewModeling
    private var disposeBag: DisposeBag = DisposeBag()
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        self.addGestureRecognizer(tap)
        self.isUserInteractionEnabled = true
        return tap
    }()

    private lazy var closeButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            .contentMode(.center)
        return closeButton
    }()

    private lazy var imageView: OWZoomableImageView = {
        return OWZoomableImageView()
    }()

    init(viewModel: OWFullScreenImageViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyIdentifiers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension OWFullScreenImageView {
    func setupViews() {
        self.alpha = 0
        UIView.animate(withDuration: Metrics.fadeAnimationDuration) {
            self.alpha = 1
        }
        self.useAsThemeStyleInjector()
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: .light).withAlphaComponent(Metrics.backgroundAlpha)
        addSubview(imageView)
        imageView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.size.equalTo(Metrics.closeButtonSize)
            make.trailing.top.equalToSuperviewSafeArea().inset(Metrics.closeButtonPadding)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle).withAlphaComponent(Metrics.backgroundAlpha)
            })
            .disposed(by: disposeBag)

        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.dismiss()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.image
            .subscribe(onNext: { [weak self] image in
                guard let self else { return }
                self.imageView.setImage(image)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss()
            })
            .disposed(by: disposeBag)
    }

    func dismiss() {
        UIView.animate(withDuration: Metrics.fadeAnimationDuration) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    func applyIdentifiers() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

//
//  OWCancelView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCancelView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "cancel_view_id"
        static let closeButtonIdentifier = "cancel_close_button_id"
        static let continueButtonIdentifier = "cancel_continue_button_id"
        static let cancelButtonIdentifier = "cancel_cancel_button_id"
        static let closeButtonTopSpacing: CGFloat = 17
        static let closeButtonTrailingSpacing: CGFloat = 19
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let titleViewTopSpacing: CGFloat = 20
        static let buttonsRadius: CGFloat = 6
        static let buttonsHeight: CGFloat = 40
        static let bottomPadding: CGFloat = 20
        static let trashIconPadding: CGFloat = 10
        static let closeButtonPadding: CGFloat = 20
        static let closeCrossIcon = "closeCrossIcon"
    }

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            .withPadding(Metrics.closeButtonPadding)
    }()

    fileprivate lazy var titleView: OWTitleSubtitleIconView = {
        return OWTitleSubtitleIconView(viewModel: viewModel.outputs.titleViewVM)
    }()

    fileprivate lazy var buttonsStackView: UIStackView = {
        return UIStackView()
            .axis(.vertical)
            .spacing(Metrics.verticalSpacing)
            .distribution(.fillEqually)
    }()

    fileprivate lazy var continueButton: UIButton = {
        return UIButton()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .setTitle(viewModel.outputs.continueButtonText, state: .normal)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .corner(radius: Metrics.buttonsRadius)
    }()

    fileprivate lazy var cancelButton: UIButton = {
        return UIButton()
            .backgroundColor(.clear)
            .textColor(OWDesignColors.G4)
            .border(width: 1, color: OWDesignColors.G4)
            .setTitle(viewModel.outputs.cancelButtonText, state: .normal)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .corner(radius: Metrics.buttonsRadius)
            .image(UIImage(spNamed: viewModel.outputs.trashIconName), state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Metrics.trashIconPadding))
    }()

    fileprivate let viewModel: OWCancelViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWCancelViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCancelView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        self.addSubviews(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea().offset(Metrics.closeButtonTopSpacing - Metrics.closeButtonPadding)
            make.trailing.equalToSuperviewSafeArea().inset(Metrics.closeButtonTrailingSpacing - Metrics.closeButtonPadding)
            make.leading.greaterThanOrEqualToSuperview()
        }

        self.addSubviews(titleView)
        titleView.OWSnp.makeConstraints { make in
            make.top.equalTo(closeButton.OWSnp.bottom).offset(Metrics.titleViewTopSpacing)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
        }

        self.addSubviews(buttonsStackView)
        buttonsStackView.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperviewSafeArea().inset(Metrics.bottomPadding)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
        }

        continueButton.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.buttonsHeight)
        }

        cancelButton.OWSnp.makeConstraints { make in
            make.height.equalTo(Metrics.buttonsHeight)
        }

        buttonsStackView.addArrangedSubview(continueButton)
        buttonsStackView.addArrangedSubview(cancelButton)
    }

    func setupObservers() {
        Observable.of(closeButton.rx.tap, continueButton.rx.tap)
            .merge()
            .bind(to: viewModel.inputs.closeTap)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton
                    .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)

                self.continueButton
                    .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle))
                    .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.continueButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyInteraction)
                self.cancelButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        continueButton.accessibilityIdentifier = Metrics.continueButtonIdentifier
        cancelButton.accessibilityIdentifier = Metrics.cancelButtonIdentifier
    }
}

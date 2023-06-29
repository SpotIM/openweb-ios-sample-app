//
//  OWReportReasonSubmittedView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 27/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWReportReasonSubmittedView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "report_reason_Submitted_view_id"
        static let closeButtonIdentifier = "report_reason_Submitted_close_button_id"
        static let gotitButtonIdentifier = "report_reason_Submitted_gotit_button_id"
        static let titleViewPrefixIdentifier = "report_reason_Submitted"
        static let closeButtonTopSpacing: CGFloat = 17
        static let closeButtonTrailingSpacing: CGFloat = 19
        static let horizontalSpacing: CGFloat = 16
        static let titleViewTopPadding: CGFloat = 20
        static let buttonRadius: CGFloat = 6
        static let buttonHeight: CGFloat = 40
        static let bottomPadding: CGFloat = 20
        static let buttonFontSize: CGFloat = 15
        static let closeButtonPadding: CGFloat = 20
        static let closeCrossIcon = "closeCrossIcon"
    }

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            .withPadding(Metrics.closeButtonPadding)
    }()

    fileprivate lazy var confirmButton: UIButton = {
        return UIButton()
                .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(.white)
                .font(OWFontBook.shared.font(style: .semiBold, size: Metrics.buttonFontSize))
                .setTitle(viewModel.outputs.confirmButtonText, state: .normal)
                .corner(radius: Metrics.buttonRadius)
    }()

    fileprivate lazy var titleView: OWTitleSubtitleIconView = {
        return OWTitleSubtitleIconView(iconName: viewModel.outputs.titleIconName,
                                       title: viewModel.outputs.title,
                                       subtitle: viewModel.outputs.subtitle,
                                       accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
    }()

    fileprivate let viewModel: OWReportReasonSubmittedViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonSubmittedViewViewModeling = OWReportReasonSubmittedViewViewModel()) {
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

fileprivate extension OWReportReasonSubmittedView {
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
            make.top.equalTo(closeButton.OWSnp.bottom).offset(Metrics.titleViewTopPadding)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
        }

        self.addSubviews(confirmButton)
        confirmButton.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.horizontalSpacing)
            make.bottom.equalToSuperviewSafeArea().inset(Metrics.bottomPadding)
            make.height.equalTo(Metrics.buttonHeight)
        }
    }

    func setupObservers() {
        Observable.of(closeButton.rx.tap, confirmButton.rx.tap)
            .merge()
            .bind(to: viewModel.inputs.closeReportReasonSubmittedTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        confirmButton.accessibilityIdentifier = Metrics.gotitButtonIdentifier
    }
}

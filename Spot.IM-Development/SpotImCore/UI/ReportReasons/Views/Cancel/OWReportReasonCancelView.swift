//
//  OWReportReasonCancelView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 24/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWReportReasonCancelView: UIView {
    fileprivate struct Metrics {
        static let identifier = "report_reason_cancel_view_id"
        static let titleViewPrefixIdentifier = "report_reason_cancel"
        static let closeButtonTopSpacing: CGFloat = 17
        static let closeButtonTrailingSpacing: CGFloat = 19
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 16
        static let titleViewTopSpacing: CGFloat = 20
        static let buttonsRadius: CGFloat = 6
        static let buttonsHeight: CGFloat = 40
        static let bottomPadding: CGFloat = 20
        static let trashIconPadding: CGFloat = 10
        static let buttonsFontSize: CGFloat = 15
    }

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var titleView: OWTitleSubtitleIconView = {
        return OWTitleSubtitleIconView(iconName: viewModel.outputs.titleIconName,
                                       title: viewModel.outputs.title,
                                       subtitle: viewModel.outputs.subtitle,
                                       accessibilityPrefixId: Metrics.titleViewPrefixIdentifier)
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
            .font(.openSans(style: .semibold, of: Metrics.buttonsFontSize))
            .corner(radius: Metrics.buttonsRadius)
    }()

    fileprivate lazy var cancelButton: UIButton = {
        return UIButton()
            .backgroundColor(.clear)
            .textColor(OWDesignColors.G4)
            .border(width: 1, color: OWDesignColors.G4)
            .setTitle(viewModel.outputs.cancelButtonText, state: .normal)
            .font(.openSans(style: .semibold, of: Metrics.buttonsFontSize))
            .corner(radius: Metrics.buttonsRadius)
            .image(UIImage(spNamed: viewModel.outputs.trashIconName), state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: Metrics.trashIconPadding))
    }()

    fileprivate let viewModel: OWReportReasonCancelViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: OWReportReasonCancelViewViewModeling = OWReportReasonCancelViewViewModel()) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWReportReasonCancelView {
    func setupViews() {
        self.addSubviews(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea().offset(Metrics.closeButtonTopSpacing)
            make.trailing.equalToSuperviewSafeArea().inset(Metrics.closeButtonTrailingSpacing)
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
            .bind(to: viewModel.inputs.closeReportReasonCancelTap)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelReportReasonCancelTap)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton
                    .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)

                self.continueButton
                    .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle))
                    .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)
    }
}

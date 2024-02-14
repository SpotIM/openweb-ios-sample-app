//
//  OWTitleView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class OWTitleView: UIView {
    fileprivate struct Metrics {
        static let horizontalPadding: CGFloat = 16
        static let titleLeadingPadding: CGFloat = 8
        static let backButtonSize: CGFloat = 24

        static let closeCrossIcon = "closeCrossIcon"
        static let backButtonIcon = "backButton"

        static let suffixIdentifier = "_title_view_id"
        static let titleLabelSuffixIdentifier = "_title_label_id"
        static let closeButtonSuffixIdentifier = "_close_button_id"
    }

    fileprivate let viewModel: OWTitleViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    fileprivate let title: String

    fileprivate lazy var backButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.backButtonIcon, supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var titleLabel: UILabel = {
        return title
            .label
            .font(OWFontBook.shared.font(typography: .bodyContext))
            .text(title)
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
    }()

    init(title: String, prefixIdentifier: String, viewModel: OWTitleViewViewModeling = OWTitleViewViewModel()) {
        self.viewModel = viewModel
        self.title = title
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility(prefixId: prefixIdentifier)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWTitleView {
    func applyAccessibility(prefixId: String) {
        self.accessibilityIdentifier = prefixId + Metrics.suffixIdentifier
        titleLabel.accessibilityIdentifier = prefixId + Metrics.titleLabelSuffixIdentifier
        closeButton.accessibilityIdentifier = prefixId + Metrics.closeButtonSuffixIdentifier
    }

    func setupViews() {
        self.backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        self.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalPadding)
            make.centerY.equalToSuperview()
        }

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.centerY.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle))
                self.closeButton.image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
                self.backButton.image(UIImage(spNamed: Metrics.backButtonIcon, supportDarkMode: true), state: .normal)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyContext)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeTap)
            .disposed(by: disposeBag)

        backButton.rx.tap
            .bind(to: viewModel.inputs.backTap)
            .disposed(by: disposeBag)

        viewModel.outputs
            .title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs
            .shouldShowBackButton
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldShow in
                OWScheduler.runOnMainThreadIfNeeded {
                    guard let self = self else { return }
                    if shouldShow {
                        self.addSubview(self.backButton)
                        self.backButton.OWSnp.makeConstraints { make in
                            make.leading.equalToSuperview().inset(Metrics.horizontalPadding)
                            make.centerY.equalToSuperview()
                            make.size.equalTo(Metrics.backButtonSize)
                        }

                        self.addSubview(self.titleLabel)
                        self.titleLabel.OWSnp.remakeConstraints { make in
                            make.leading.equalTo(self.backButton.OWSnp.trailing).offset(Metrics.titleLeadingPadding)
                            make.centerY.equalToSuperview()
                        }
                    } else {
                        self.backButton.removeFromSuperview()
                        self.titleLabel.OWSnp.remakeConstraints { make in
                            make.leading.equalToSuperview().offset(Metrics.horizontalPadding)
                            make.centerY.equalToSuperview()
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

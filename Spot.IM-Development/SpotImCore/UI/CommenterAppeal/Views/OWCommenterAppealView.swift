//
//  OWCommenterAppealView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class OWCommenterAppealView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let closeButtonSize: CGFloat = 28
        static let navigationTitleTrailingPadding: CGFloat = 8
        static let navigationBottomPadding: CGFloat = 10
        static let horizontalPadding: CGFloat = 16
        static let buttonsRadius: CGFloat = 6
        static let submitDisabledOpacity: CGFloat = 0.5
        static let textViewHorizontalPadding: CGFloat = 10
        static let textViewHeight: CGFloat = 62
        static let buttonsPadding: CGFloat = 16
        static let buttonsHeight: CGFloat = 40
//        static let verticalPadding: CGFloat = 20
//        static let titleTopPadding: CGFloat = 12
//        static let spaceBetweenParagraphs: CGFloat = 16
//        static let buttomBottomPadding: CGFloat = 36
        static let buttonTextPadding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
//        static let appealLabelTopPadding: CGFloat = 24
//
        static let identifier = "commenter_appeal_view_id"
        static let titleLabelIdentifier = "commenter_appeal_title_id"
        static let closeButtonIdentifier = "commenter_appeal_close_button_id"
        static let footerViewIdentifier = "commenter_appeal_footer_view_id"
        static let prefixIdentifier = "commenter_appeal"
        static let cancelButtonIdentifier = "commenter_appeal_cancel_buton_id"
        static let submitButtonIdentifier = "commenter_appeal_submit_buton_id"
//        static let gotItButtonIdentifier = "clarity_details_got_it_button_id"
    }

    fileprivate lazy var titleLabel: UILabel = {
        return UILabel()
            .text(OWLocalizationManager.shared.localizedString(key: "CommenterAppealTitle"))
            .font(OWFontBook.shared.font(typography: .bodyContext))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton()
            .image(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), state: .normal)
    }()

    fileprivate lazy var topContainerView: UIView = {
        let topContainerView = UIView()
            .enforceSemanticAttribute()

        topContainerView.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.navigationBottomPadding)
            make.trailing.equalToSuperview().inset(Metrics.horizontalPadding)
            make.size.equalTo(Metrics.closeButtonSize)
        }

        topContainerView.addSubview(titleLabel)
        titleLabel.OWSnp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(Metrics.navigationBottomPadding)
            make.leading.equalToSuperview().offset(Metrics.horizontalPadding)
            make.trailing.equalTo(closeButton.OWSnp.leading).inset(Metrics.navigationTitleTrailingPadding)
        }

        return topContainerView
    }()

    fileprivate lazy var scrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentLayoutGuide.OWSnp.makeConstraints { make in
            make.width.equalTo(scrollView)
        }
        return scrollView
    }()

    fileprivate lazy var footerView: UIView = {
        let footerView = UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light))
        footerView.apply(shadow: .standard, direction: .up)
        return footerView
    }()
    fileprivate lazy var textView: OWTextView = {
        return OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
                .alpha(0)
    }()
    fileprivate lazy var footerButtonsStackView: UIStackView = {
        return UIStackView()
            .spacing(Metrics.buttonsPadding)
            .axis(.horizontal)
            .distribution(.fillEqually)
    }()
    fileprivate lazy var cancelButton: UIButton = {
        return UIButton()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: .light))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .setTitle(OWLocalizationManager.shared.localizedString(key: "Cancel"), state: .normal)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .withPadding(Metrics.buttonTextPadding)
            .corner(radius: Metrics.buttonsRadius)
    }()
    fileprivate lazy var submitButton: OWLoaderButton = {
        return OWLoaderButton()
            .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))
            .textColor(.white)
            .corner(radius: Metrics.buttonsRadius)
            .isEnabled(false)
            .font(OWFontBook.shared.font(typography: .bodyInteraction))
            .withPadding(Metrics.buttonTextPadding)
            .alpha(Metrics.submitDisabledOpacity)
            .setTitle("Submit", state: .normal) // TODO: from VM according to state (can be try again)
    }()

    fileprivate var textViewHeightConstraint: OWConstraint? = nil

    fileprivate let viewModel: OWCommenterAppealViewViewModeling
    fileprivate var disposeBag: DisposeBag

    init(viewModel: OWCommenterAppealViewViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        super.init(frame: .zero)

        setupViews()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommenterAppealView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.useAsThemeStyleInjector()

        self.addSubview(topContainerView)
        topContainerView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.addSubview(scrollView)
        scrollView.OWSnp.makeConstraints { make in
            make.top.equalTo(topContainerView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        self.addSubviews(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(scrollView.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        footerView.addSubview(textView)
        textView.OWSnp.makeConstraints { [weak self] make in
            guard let self = self else { return }
            make.top.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.textViewHorizontalPadding)
            self.textViewHeightConstraint = make.height.equalTo(0).constraint
        }

        footerView.addSubview(footerButtonsStackView)
        footerButtonsStackView.OWSnp.makeConstraints { make in
            make.top.equalTo(textView.OWSnp.bottom).offset(Metrics.buttonsPadding)
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.buttonsPadding)
            make.bottom.equalToSuperviewSafeArea().inset(Metrics.buttonsPadding)
        }
        footerButtonsStackView.addArrangedSubview(cancelButton)
        footerButtonsStackView.addArrangedSubview(submitButton)
    }

    func setupObservers() {
        closeButton.rx.tap
            .bind(to: viewModel.inputs.closeClick)
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor4, themeStyle: currentStyle)
                self.titleLabel.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.closeButton.setImage(UIImage(spNamed: "closeCrossIcon", supportDarkMode: true), for: .normal)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.cancelButton.backgroundColor = OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle)
                self.cancelButton.setTitleColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle), for: .normal)
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.titleLabel.font = OWFontBook.shared.font(typography: .bodyContext)
                self.cancelButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyInteraction)
                self.submitButton.titleLabel?.font = OWFontBook.shared.font(typography: .bodyInteraction)
            })
            .disposed(by: disposeBag)
    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        titleLabel.accessibilityIdentifier = Metrics.titleLabelIdentifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        footerView.accessibilityIdentifier = Metrics.footerViewIdentifier
        cancelButton.accessibilityIdentifier = Metrics.cancelButtonIdentifier
        submitButton.accessibilityIdentifier = Metrics.submitButtonIdentifier
    }
}

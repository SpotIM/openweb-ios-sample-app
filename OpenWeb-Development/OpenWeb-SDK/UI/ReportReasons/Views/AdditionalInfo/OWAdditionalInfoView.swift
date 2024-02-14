//
//  OWAdditionalInfoView.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWAdditionalInfoView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "additional_info_view_id"
        static let cancelButtonIdentifier = "additional_info_cancel_button_id"
        static let submitButtonIdentifier = "additional_info_submit_button_id"
        static let footerViewIdentifier = "additional_info_footer_view_id"
        static let prefixIdentifier = "additional_info"
        static let titleViewHeight: CGFloat = 56
        static let titleLeadingPadding: CGFloat = 16
        static let buttonsRadius: CGFloat = 6
        static let buttonsPadding: CGFloat = 15
        static let buttonsHeight: CGFloat = 40
        static let textViewPadding: CGFloat = 10
        static let footerViewHeight: CGFloat = 72
        static let keyboardAnimationDuration: CGFloat = 0.25
        static let footerBottomToSuperviewPriority: CGFloat = 750
        static let footerBottomToKeyboardPriority: CGFloat = 1000
        static let submitDisabledOpacity: CGFloat = 0.5
        static let becomeFirstResponderDelay = 550 // miliseconds
    }

    fileprivate let viewModel: OWAdditionalInfoViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate var footerBottomPaddingConstraint: OWConstraint? = nil
    fileprivate var hasLayoutSubviewsFirstTime = false

    fileprivate lazy var titleView: OWTitleView = {
        return OWTitleView(title: viewModel.outputs.titleText,
                           prefixIdentifier: Metrics.prefixIdentifier,
                           viewModel: viewModel.outputs.titleViewVM)
    }()

    fileprivate lazy var textView: OWTextView = {
        return OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
    }()

    fileprivate lazy var footerView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var footerStackView: UIStackView = {
        return UIStackView()
            .spacing(Metrics.buttonsPadding)
            .axis(.horizontal)
            .distribution(.fillEqually)
    }()

    fileprivate lazy var cancelButton: UIButton = {
        return UIButton()
                .backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .setTitle(viewModel.outputs.cancelButtonText, state: .normal)
                .corner(radius: Metrics.buttonsRadius)
    }()

    fileprivate lazy var submitButton: OWLoaderButton = {
        return OWLoaderButton()
                .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(.white)
                .corner(radius: Metrics.buttonsRadius)
                .isEnabled(false)
    }()

    init(viewModel: OWAdditionalInfoViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: CGRect.zero)
        setupObservers()
        setupViews()
        applyAccessibility()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if viewModel.outputs.viewableMode == .partOfFlow || !hasLayoutSubviewsFirstTime {
            self.viewModel.outputs.textViewVM.inputs.becomeFirstResponderCallWithDelay.onNext(Metrics.becomeFirstResponderDelay)
            hasLayoutSubviewsFirstTime = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWAdditionalInfoView {
    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        cancelButton.accessibilityIdentifier = Metrics.cancelButtonIdentifier
        submitButton.accessibilityIdentifier = Metrics.submitButtonIdentifier
        footerView.accessibilityIdentifier = Metrics.footerViewIdentifier
    }

    func setupViews() {
        self.useAsThemeStyleInjector()

        backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)

        let shouldShowTitleView = viewModel.outputs.shouldShowTitleView
        if shouldShowTitleView {
            self.addSubviews(titleView)
            titleView.OWSnp.makeConstraints { make in
                make.leading.top.trailing.equalToSuperviewSafeArea()
                make.height.equalTo(Metrics.titleViewHeight)
            }
        }

        self.addSubviews(textView)
        textView.OWSnp.makeConstraints { make in
            if shouldShowTitleView {
                make.top.equalTo(titleView.OWSnp.bottom).offset(Metrics.textViewPadding)
            } else {
                make.top.equalToSuperviewSafeArea().offset(Metrics.textViewPadding)
            }
            make.leading.trailing.equalToSuperviewSafeArea().inset(Metrics.textViewPadding)
        }

        self.addSubviews(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.top.equalTo(textView.OWSnp.bottom)
            make.leading.trailing.equalToSuperviewSafeArea()
            make.bottom.equalToSuperviewSafeArea().priority(Metrics.footerBottomToSuperviewPriority)
            footerBottomPaddingConstraint = make.bottom.equalToSuperview().priority(Metrics.footerBottomToKeyboardPriority).constraint
            make.height.equalTo(Metrics.footerViewHeight)
        }
        footerBottomPaddingConstraint?.isActive = false

        footerView.addSubview(footerStackView)
        footerStackView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Metrics.buttonsPadding)
            make.height.equalTo(Metrics.buttonsHeight)
            make.center.equalToSuperview()
        }

        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(submitButton)
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle).cgColor
                self.titleView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.cancelButton.backgroundColor(OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle), state: .normal)
                self.cancelButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
                self.submitButton.backgroundColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.submitButtonText
            .bind(to: submitButton.rx.title(for: .normal))
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.outputs.viewableMode == .independent {
                    self.viewModel.outputs.textViewVM.inputs.resignFirstResponderCall.onNext()
                }
            })
            .bind(to: viewModel.inputs.cancelAdditionalInfoTap)
            .disposed(by: disposeBag)

        submitButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.viewModel.outputs.viewableMode == .independent {
                    self.viewModel.outputs.textViewVM.inputs.resignFirstResponderCall.onNext()
                }
            })
            .bind(to: viewModel.inputs.submitAdditionalInfoTap)
            .disposed(by: disposeBag)

        viewModel.outputs.isSubmitEnabled
            .map { [weak self] isSubmitEnabled -> Bool in
                guard let self = self else { return isSubmitEnabled }
                self.submitButton.alpha = isSubmitEnabled ? 1 : Metrics.submitDisabledOpacity
                return isSubmitEnabled
            }
            .bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.outputs.submitInProgressChanged
            .bind(to: submitButton.rx.isLoading)
            .disposed(by: disposeBag)

        textView.viewModel.outputs.textViewText
            .bind(to: viewModel.inputs.additionalInfoTextChange)
            .disposed(by: disposeBag)

        viewModel.outputs.titleViewVM.outputs.closeTapped
            .bind(to: viewModel.inputs.closeAdditionalInfoTap)
            .disposed(by: disposeBag)

        if viewModel.outputs.viewableMode == .partOfFlow {
            let keyboardShowHeight = NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillShowNotification)
                .map { notification -> CGFloat in
                    // swiftlint:disable line_length
                    let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
                    // swiftlint:enable line_length
                    return height ?? 0
                }

            let keyboardChangeHeight = NotificationCenter.default.rx
                .notification(UIResponder.keyboardDidChangeFrameNotification)
                .map { notification -> CGFloat in
                    // swiftlint:disable line_length
                    let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height
                    // swiftlint:enable line_length
                    return height ?? 0
                }

            let keyboardHideHeight = NotificationCenter.default.rx
                .notification(UIResponder.keyboardWillHideNotification)
                .map { _ -> CGFloat in
                    0
                }

            let keyboardHeight = Observable.from([keyboardShowHeight, keyboardHideHeight, keyboardChangeHeight])
                .merge()

            keyboardHeight
                .subscribe(onNext: { [weak self] height in
                    guard let self = self else { return }
                    self.footerBottomPaddingConstraint?.update(inset: height)
                    self.footerBottomPaddingConstraint?.isActive = height > 0
                    UIView.animate(withDuration: Metrics.keyboardAnimationDuration) {
                        self.layoutIfNeeded()
                    }
                })
                .disposed(by: disposeBag)
        }
    }
}

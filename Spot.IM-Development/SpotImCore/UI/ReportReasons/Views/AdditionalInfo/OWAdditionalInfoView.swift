//
//  OWAdditionalInfoView.swift
//  SpotImCore
//
//  Created by Refael Sommer on 01/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWAdditionalInfoView: UIView {
    fileprivate struct Metrics {
        static let identifier = "additional_info_view_id"
        static let cancelButtonIdentifier = "additional_info_cancel_button_id"
        static let submitButtonIdentifier = "additional_info_submit_button_id"
        static let prefixIdentifier = "additional_info"
        static let titleViewHeight: CGFloat = 56
        static let titleLeadingPadding: CGFloat = 16
        static let buttonsRadius: CGFloat = 6
        static let buttonsPadding: CGFloat = 15
        static let buttonsHeight: CGFloat = 40
        static let textViewPadding: CGFloat = 10
        static let footerViewHeight: CGFloat = 72
        static let keyboardAnimationDuration: CGFloat = 0.25
        static let becomeFirstResponderDelay: CGFloat = 0.5
        static let footerBottomToSuperviewPriority: CGFloat = 750
        static let footerBottomToKeyboardPriority: CGFloat = 1000
    }

    fileprivate let viewModel: OWAdditionalInfoViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate var footerBottomPaddingConstraint: OWConstraint? = nil

    fileprivate lazy var titleView: OWTitleView = {
        return OWTitleView(title: viewModel.outputs.titleText,
                           prefixIdentifier: Metrics.prefixIdentifier)
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

    fileprivate lazy var submitButton: UIButton = {
        return UIButton()
                .backgroundColor(OWColorPalette.shared.color(type: .brandColor, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
                .textColor(.white)
                .setTitle(viewModel.outputs.submitButtonText, state: .normal)
                .corner(radius: Metrics.buttonsRadius)
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Metrics.becomeFirstResponderDelay) { [weak self] in
            guard let self = self else { return }
            self.viewModel.outputs.textViewVM.inputs.becomeFirstResponderCall.onNext()
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
    }

    func setupViews() {
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
            footerBottomPaddingConstraint = make.bottom
                                                .equalToSuperview()
                                                .priority(Metrics.footerBottomToKeyboardPriority)
                                                .constraint
            make.height.equalTo(Metrics.footerViewHeight)
        }
        footerBottomPaddingConstraint?.isActive = false

        footerView.addSubview(footerStackView)
        footerStackView.OWSnp.makeConstraints { make in
            make.top.equalTo(textView.OWSnp.bottom).offset(Metrics.textViewPadding)
            make.leading.trailing.equalToSuperview().inset(Metrics.buttonsPadding)
            make.height.equalTo(Metrics.buttonsHeight)
            make.bottom.equalToSuperview().inset(Metrics.buttonsPadding)
        }

        footerStackView.addArrangedSubview(cancelButton)
        footerStackView.addArrangedSubview(submitButton)
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.layer.borderColor = OWColorPalette.shared.color(type: .brandColor, themeStyle: currentStyle).cgColor
                self.titleView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.cancelButton.setBackgroundColor(color: OWColorPalette.shared.color(type: .separatorColor2, themeStyle: currentStyle), forState: .normal)
                self.cancelButton.textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
            })
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .bind(to: viewModel.inputs.cancelAdditionalInfoTap)
            .disposed(by: disposeBag)

        Observable.combineLatest(submitButton.rx.tap, textView.viewModel.outputs.textViewText)
            .subscribe(onNext: { [weak self] _, text in
                guard let self = self else { return }
                self.viewModel.inputs.submitAdditionalInfoTap.onNext(text)
            })
            .disposed(by: disposeBag)

        titleView.outputs.closeTapped
            .bind(to: viewModel.inputs.cancelAdditionalInfoTap)
            .disposed(by: disposeBag)

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

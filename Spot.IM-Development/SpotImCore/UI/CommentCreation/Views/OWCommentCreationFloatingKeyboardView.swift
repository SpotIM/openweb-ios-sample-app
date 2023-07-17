//
//  OWCommentCreationFloatingKeyboardView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationFloatingKeyboardView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_floating_keyboard_view_id"
        static let prefixIdentifier = "comment_creation_floating_keyboard"
        static let userAvatarLeadingPadding: CGFloat = 20
        static let footerTrailingPadding: CGFloat = 12
        static let userAvatarBottomPadding: CGFloat = 12
        static let userAvatarSize: CGFloat = 40
        static let textViewHorizontalPadding: CGFloat = 10
        static let textViewVerticalPadding: CGFloat = 12
        static let sendImageIcon = "sendCommentIcon"
        static let sendButtonSize: CGFloat = 35
        static let delayCloseDuration = 300 // miliseconds
    }

    fileprivate lazy var footerView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var textViewObject: OWTextView = {
        return OWTextView(viewModel: viewModel.outputs.textViewVM,
                          prefixIdentifier: Metrics.prefixIdentifier)
    }()

    fileprivate lazy var userAvatarView: OWAvatarView = {
        let avatarView = OWAvatarView()
        avatarView.backgroundColor = .clear
        return avatarView
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton(frame: .zero)
            .backgroundColor(.clear)
    }()

    fileprivate lazy var sendButton: UIButton = {
        let image = UIImage(spNamed: Metrics.sendImageIcon, supportDarkMode: false)
        return UIButton()
            .image(image, state: .normal)
            .setAlpha(0)
            .enforceSemanticAttribute()
    }()

    fileprivate let viewModel: OWCommentCreationFloatingKeyboardViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationFloatingKeyboardViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.enforceSemanticAttribute()
        userAvatarView.configure(with: viewModel.outputs.avatarViewVM)
        setupViews()
        setupObservers()
        applyAccessibility()
        self.viewModel.outputs.textViewVM.inputs.becomeFirstResponderCall.onNext()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardView {
    func setupViews() {
        self.useAsThemeStyleInjector()
        self.backgroundColor = .clear

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }

        footerView.addSubview(textViewObject)
        footerView.addSubview(userAvatarView)

        textViewObject.OWSnp.makeConstraints { make in
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.top.equalToSuperview().inset(Metrics.textViewVerticalPadding)
        }

        userAvatarView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.userAvatarLeadingPadding)
            make.centerY.equalTo(textViewObject.OWSnp.centerY)
            make.size.equalTo(Metrics.userAvatarSize)
        }

        footerView.addSubview(sendButton)
        sendButton.OWSnp.makeConstraints { make in
            make.leading.equalTo(textViewObject.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(-Metrics.sendButtonSize + Metrics.textViewHorizontalPadding)
            make.size.equalTo(Metrics.sendButtonSize)
            make.bottom.equalTo(textViewObject.OWSnp.bottom)
        }

        if case let OWAccessoryViewStrategy.bottomToolbar(toolbar) = viewModel.outputs.accessoryViewStrategy {
            footerView.addSubview(toolbar)
            toolbar.OWSnp.makeConstraints { make in
                make.top.equalTo(textViewObject.OWSnp.bottom)
                make.leading.trailing.bottom.equalToSuperview()
            }
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .bind(to: viewModel.outputs.textViewVM.inputs.resignFirstResponderCall)
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .delay(.milliseconds(Metrics.delayCloseDuration), scheduler: MainScheduler.instance)
            .bind(to: viewModel.inputs.closeButtonTap)
            .disposed(by: disposeBag)

        // keyboard will show
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.sendButton.alpha(1)
                    self.sendButton.OWSnp.updateConstraints { make in
                        make.trailing.equalToSuperview().inset(Metrics.textViewHorizontalPadding)
                    }
                    footerView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        // keyboard will hide
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.sendButton.alpha(0)
                    self.sendButton.OWSnp.updateConstraints { make in
                        make.trailing.equalToSuperview().inset(-Metrics.sendButtonSize + Metrics.textViewHorizontalPadding)
                    }
                    footerView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}


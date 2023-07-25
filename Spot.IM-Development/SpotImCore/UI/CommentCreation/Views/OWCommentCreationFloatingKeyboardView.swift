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
        static let sendButtonHorizontalPadding: CGFloat = 5
        static let sendImageIcon = "sendCommentIcon"
        static let editImageIcon = "commentCreationEditIcon"
        static let replyImageIcon = "commentCreationReplyIcon"
        static let sendButtonSize: CGFloat = 35
        static let sendButtonImageSize: CGFloat = 24
        static let delayCloseDuration = 400 // miliseconds
        static let toolbarAnimationMilisecondsDuration = 300 // miliseconds
        static let toolbarAnimationSecondsDuration = CGFloat(toolbarAnimationMilisecondsDuration) / 1000 // seconds
        static let underFooterHeight: CGFloat = 300
        static let headerIconLeadingPadding: CGFloat = 20
        static let headerTitleLeadingPadding: CGFloat = 14
        static let headerTrailingPadding: CGFloat = 10
        static let headerTitleFontSize: CGFloat = 15
        static let headerHeight: CGFloat = 40
        static let headerIconSize: CGFloat = 16
    }

    fileprivate lazy var underFooterView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var headerTitleLabel: UILabel = {
        let currentStyle = viewModel.outputs.servicesProvider.themeStyleService().currentStyle
        return UILabel()
            .font(OWFontBook.shared.font(style: .regular, size: Metrics.headerTitleFontSize))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
    }()

    fileprivate lazy var headerIconView: UIImageView = {
        let currentStyle = viewModel.outputs.servicesProvider.themeStyleService().currentStyle
        return UIImageView()
            .tintColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle))
    }()

    fileprivate lazy var headerView: UIView = {
        let headerView = UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))

        switch viewModel.outputs.commentType {
        case .comment:
            break
        case .edit(comment: let comment):
            headerIconView.image(UIImage(spNamed: Metrics.editImageIcon))
            headerTitleLabel.text = OWLocalizationManager.shared.localizedString(key: "Editing comment")
        case .replyToComment(originComment: let originComment):
            headerIconView.image(UIImage(spNamed: Metrics.replyImageIcon))
            var name = ""
            if let userId = originComment.userId,
               let user = viewModel.outputs.servicesProvider.usersService().get(userId: userId),
               let displayName = user.displayName {
                name = displayName
            }
            var attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "Replying to "))

            let attrs = [NSAttributedString.Key.font: OWFontBook.shared.font(style: .bold, size: Metrics.headerTitleFontSize)]
            let boldUserNameString = NSMutableAttributedString(string: name, attributes: attrs)

            attributedString.append(boldUserNameString)
            headerTitleLabel.attributedText = attributedString
        }

        headerView.addSubview(headerIconView)
        headerView.addSubview(headerTitleLabel)

        headerIconView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.headerIconLeadingPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.headerIconSize)
        }

        headerTitleLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(headerIconView.OWSnp.trailing).offset(Metrics.headerTitleLeadingPadding)
            make.trailing.greaterThanOrEqualToSuperview().inset(Metrics.headerTrailingPadding)
            make.centerY.equalToSuperview()
        }
        return headerView
    }()

    fileprivate lazy var footerView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .clipsToBounds(true)
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
            .imageEdgeInsets(UIEdgeInsets(top: Metrics.sendButtonSize - Metrics.sendButtonImageSize,
                                          left: 0,
                                          bottom: 0,
                                          right: 0))
            .setAlpha(0)
            .enforceSemanticAttribute()
            .tintColor(OWColorPalette.shared.color(type: .brandColor,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var toolbar: UIView? = {
        if case let OWAccessoryViewStrategy.bottomToolbar(toolbar) = viewModel.outputs.accessoryViewStrategy {
            return toolbar
        }
        return nil
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
    }

    fileprivate var firstLayoutSubviewsDone = false
    override func layoutSubviews() {
        if !firstLayoutSubviewsDone,
           let toolbar = toolbar,
           subviews.contains(toolbar) {
            firstLayoutSubviewsDone = true
            let delayKeyboard = Metrics.toolbarAnimationMilisecondsDuration
            viewModel.outputs.textViewVM.inputs.becomeFirstResponderCall.onNext(delayKeyboard)
            updateToolbarConstraints(hidden: true)
            layoutIfNeeded()
            UIView.animate(withDuration: Metrics.toolbarAnimationSecondsDuration) { [weak self] in
                guard let self = self else { return }
                self.updateToolbarConstraints(hidden: false)
                self.layoutIfNeeded()
            }
        } else if !firstLayoutSubviewsDone {
            firstLayoutSubviewsDone = true
            self.viewModel.outputs.textViewVM.inputs.becomeFirstResponderCall.onNext(0)
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        firstLayoutSubviewsDone = false
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        // TODO add all views
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardView {
    func setupViews() {
        self.clipsToBounds = false
        self.useAsThemeStyleInjector()
        self.backgroundColor = .clear

        self.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.OWSnp.bottom)
        }

        switch viewModel.outputs.commentType {
        case .comment:
            break
        case .edit, .replyToComment:
            self.addSubview(headerView)
            self.bringSubviewToFront(footerView)
            headerView.OWSnp.makeConstraints { make in
                make.bottom.equalTo(footerView.OWSnp.top).inset(Metrics.headerHeight)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Metrics.headerHeight)
            }
        }
        footerView.addSubview(textViewObject)
        footerView.addSubview(userAvatarView)

        userAvatarView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperview().inset(Metrics.userAvatarLeadingPadding)
            make.bottom.equalTo(textViewObject.OWSnp.bottom)
            make.size.equalTo(Metrics.userAvatarSize)
        }

        footerView.addSubview(sendButton)
        sendButton.OWSnp.makeConstraints { make in
            make.leading.equalTo(textViewObject.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.trailing.equalToSuperview().inset(-Metrics.sendButtonSize + Metrics.textViewHorizontalPadding)
            make.size.equalTo(Metrics.sendButtonSize)
            make.bottom.equalTo(textViewObject.OWSnp.bottom)
        }

        textViewObject.OWSnp.makeConstraints { make in
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.top.bottom.equalToSuperview().inset(Metrics.textViewVerticalPadding)
        }

        if let toolbar = toolbar {
            self.addSubview(toolbar)
            updateToolbarConstraints(hidden: true)
        }

        self.addSubview(underFooterView)
        underFooterView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.OWSnp.bottom)
            make.height.equalTo(Metrics.underFooterHeight)
        }
    }

    func updateToolbarConstraints(hidden: Bool) {
        if let toolbar = toolbar {
            toolbar.OWSnp.removeConstraints()
            footerView.OWSnp.removeConstraints()
            if hidden {
                toolbar.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(footerView.OWSnp.bottom)
                }

                footerView.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(self.safeAreaLayoutGuide)
                }
            } else {
                toolbar.OWSnp.makeConstraints { make in
                    make.top.equalTo(textViewObject.OWSnp.bottom)
                    make.leading.trailing.bottom.equalToSuperview()
                }

                footerView.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(toolbar.OWSnp.top)
                }
            }
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.headerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.headerIconView.tintColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.headerTitleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.underFooterView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .flatMap({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                if self.toolbar != nil {
                    self.updateToolbarConstraints(hidden: true)
                    UIView.animate(withDuration: Metrics.toolbarAnimationSecondsDuration) { [weak self] in
                        guard let self = self else { return }
                        self.layoutIfNeeded()
                    }
                    return Observable.just(()).delay(.milliseconds(Metrics.toolbarAnimationMilisecondsDuration), scheduler: MainScheduler.instance)
                }
                return Observable.just(())
            })
            .bind(to: viewModel.outputs.textViewVM.inputs.resignFirstResponderCall)
            .disposed(by: disposeBag)

        closeButton.rx.tap
            .delay(.milliseconds(Metrics.delayCloseDuration + (toolbar == nil ? 0 : Metrics.toolbarAnimationMilisecondsDuration)), scheduler: MainScheduler.instance)
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
                        make.leading.equalTo(self.textViewObject.OWSnp.trailing).offset(Metrics.sendButtonHorizontalPadding)
                        make.trailing.equalToSuperview().inset(Metrics.textViewHorizontalPadding)
                    }
                    if case .comment = self.viewModel.outputs.commentType {} else {
                        self.headerView.OWSnp.updateConstraints { make in
                            make.bottom.equalTo(self.footerView.OWSnp.top).inset(0)
                        }
                        self.headerView.layoutIfNeeded()
                    }
                    self.footerView.layoutIfNeeded()
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
                    self.textViewObject.layer.borderColor = OWColorPalette.shared.color(type: .borderColor1,
                                                                                        themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor
                    self.sendButton.alpha(0)
                    self.sendButton.OWSnp.updateConstraints { make in
                        make.leading.equalTo(self.textViewObject.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
                        make.trailing.equalToSuperview().inset(-Metrics.sendButtonSize + Metrics.textViewHorizontalPadding)
                    }
                    if case .comment = self.viewModel.outputs.commentType {} else {
                        self.headerView.OWSnp.updateConstraints { make in
                            make.bottom.equalTo(self.footerView.OWSnp.top).inset(Metrics.headerHeight)
                        }
                        self.headerView.layoutIfNeeded()
                    }
                    self.footerView.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}


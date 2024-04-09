//
//  OWCommentCreationFloatingKeyboardView.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationFloatingKeyboardView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_floating_keyboard_view_id"
        static let mainContainerIdentifier = "comment_creation_floating_keyboard_main_container_view_id"
        static let underFooterViewIdentifier = "comment_creation_floating_keyboard_under_footer_view_id"
        static let headerViewIdentifier = "comment_creation_floating_keyboard_header_view_id"
        static let headerCloseButtonIdentifier = "comment_creation_floating_keyboard_header_close_button_id"
        static let headerTitleLabelIdentifier = "comment_creation_floating_keyboard_header_title_label_id"
        static let closeButtonIdentifier = "comment_creation_floating_keyboard_close_button_id"
        static let ctaButtonIdentifier = "comment_creation_floating_keyboard_cta_button_id"
        static let toolbarIdentifier = "comment_creation_floating_keyboard_toolbar_view_id"
        static let prefixIdentifier = "comment_creation_floating_keyboard"
        static let lineSeparatorIdentifier = "comment_creation_floating_keyboard_line_separator_id"
        static let userAvatarLeadingPadding: CGFloat = 16
        static let footerTrailingPadding: CGFloat = 12
        static let userAvatarBottomPadding: CGFloat = 12
        static let userAvatarSize: CGFloat = 40
        static let textViewHorizontalPadding: CGFloat = 10
        static let ctaButtonHorizontalPadding: CGFloat = 5
        static let closeCrossIcon = "closeCrossIcon"
        static let editImageIcon = "commentCreationEditIcon"
        static let replyImageIcon = "commentCreationReplyIcon"
        static let ctaButtonSize: CGFloat = 35
        static let ctaButtonImageSize: CGFloat = 24
        static let closeHeaderDuration = 0.2 // seconds
        static let toolbarAnimationMilisecondsDuration = 400 // miliseconds
        static let toolbarAnimationSecondsDuration = CGFloat(toolbarAnimationMilisecondsDuration) / 1000 // seconds
        static let delayKeyboard = 0 // No delay
        static let underFooterHeight: CGFloat = 300
        static let headerIconLeadingPadding: CGFloat = 20
        static let headerTitleLeadingPadding: CGFloat = 14
        static let headerTrailingPadding: CGFloat = 20
        static let headerTitleFontSize: CGFloat = 15
        static let headerHeight: CGFloat = 40
        static let headerIconSize: CGFloat = 16
        static let floatingBackgroungColor = UIColor.black.withAlphaComponent(0.3)
        static let trailingLandscapeMargin: CGFloat = 56.0
        static let leadingLandscapeMargin: CGFloat = 66.0
        static let errorToastBottomPadding: CGFloat = 8.0
        static func headerIconViewIdentifier(commentType type: OWCommentCreationTypeInternal) -> String {
            return "comment_creation_floating_keyboard_header_\(type.identifierDescription)_icon_view_id"
        }
    }

    var toastView: OWToastView? = nil

    fileprivate var keyboardWasHidden = true
    fileprivate var toolbarBottomConstraint: OWConstraint?

    fileprivate lazy var mainContainer: OWFloatingKeyboardMainContainerView = {
        return OWFloatingKeyboardMainContainerView(frame: .zero)
            .backgroundColor(.clear)
    }()

    fileprivate lazy var underFooterView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var headerCloseButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
            .contentMode(.center)
        return closeButton
    }()

    fileprivate lazy var headerTitleLabel: UILabel = {
        let currentStyle = viewModel.outputs.servicesProvider.themeStyleService().currentStyle
        return UILabel()
            .font(OWFontBook.shared.font(typography: .bodyText))
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
            headerTitleLabel.text = OWLocalizationManager.shared.localizedString(key: "EditingComment")
        case .replyToComment(originComment: let originComment):
            headerIconView.image(UIImage(spNamed: Metrics.replyImageIcon))
            var name = ""
            if let userId = originComment.userId,
               let user = viewModel.outputs.servicesProvider.usersService().get(userId: userId),
               let displayName = user.displayName {
                name = displayName
            }
            var attributedString = NSMutableAttributedString(string: OWLocalizationManager.shared.localizedString(key: "ReplyingTo"))

            let attrs = [NSAttributedString.Key.font: OWFontBook.shared.font(typography: .bodyContext)]
            let boldUserNameString = NSMutableAttributedString(string: name, attributes: attrs)

            attributedString.append(boldUserNameString)
            headerTitleLabel.attributedText = attributedString
        }

        headerView.addSubview(headerIconView)
        headerView.addSubview(headerTitleLabel)
        headerView.addSubview(headerCloseButton)

        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let isLandscape = currentOrientation == .landscape

        headerIconView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.leadingLandscapeMargin : Metrics.headerIconLeadingPadding)
            make.centerY.equalToSuperview()
            make.size.equalTo(Metrics.headerIconSize)
        }

        headerTitleLabel.OWSnp.makeConstraints { make in
            make.leading.equalTo(headerIconView.OWSnp.trailing).offset(Metrics.headerTitleLeadingPadding)
            make.trailing.greaterThanOrEqualTo(headerCloseButton.OWSnp.leading).inset(Metrics.headerTrailingPadding)
            make.centerY.equalToSuperview()
        }

        headerCloseButton.OWSnp.makeConstraints { make in
            make.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.trailingLandscapeMargin : Metrics.headerTrailingPadding)
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

    fileprivate lazy var lineSeparator: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var closeButton: UIButton = {
        return UIButton(frame: .zero)
            .backgroundColor(.clear)
    }()

    fileprivate lazy var ctaButton: OWLoaderButton = {
        return OWLoaderButton()
            .image(viewModel.outputs.ctaIcon, state: .normal)
            .imageEdgeInsets(UIEdgeInsets(top: Metrics.ctaButtonSize - Metrics.ctaButtonImageSize,
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
        applyAccessibility()
        setupObservers()
    }

    fileprivate var firstLayoutSubviewsDone = false
    override func layoutSubviews() {
        if !firstLayoutSubviewsDone,
           let toolbar = toolbar,
           mainContainer.subviews.contains(toolbar) {
            firstLayoutSubviewsDone = true
            viewModel.outputs.textViewVM.inputs.becomeFirstResponderCallWithDelay.onNext(Metrics.delayKeyboard)
            updateToolbarConstraints(hidden: true)
            mainContainer.layoutIfNeeded()
            UIView.animate(withDuration: Metrics.toolbarAnimationSecondsDuration) { [weak self] in
                guard let self = self else { return }
                self.updateToolbarConstraints(hidden: false)
                self.mainContainer.layoutIfNeeded()
            }
        } else if !firstLayoutSubviewsDone {
            firstLayoutSubviewsDone = true
            self.viewModel.outputs.textViewVM.inputs.becomeFirstResponderCallWithDelay.onNext(0)
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        firstLayoutSubviewsDone = false
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        mainContainer.accessibilityIdentifier = Metrics.mainContainerIdentifier
        underFooterView.accessibilityIdentifier = Metrics.underFooterViewIdentifier
        headerView.accessibilityIdentifier = Metrics.headerViewIdentifier
        headerCloseButton.accessibilityIdentifier = Metrics.headerCloseButtonIdentifier
        headerTitleLabel.accessibilityIdentifier = Metrics.headerTitleLabelIdentifier
        closeButton.accessibilityIdentifier = Metrics.closeButtonIdentifier
        ctaButton.accessibilityIdentifier = Metrics.ctaButtonIdentifier
        toolbar?.accessibilityIdentifier = Metrics.toolbarIdentifier
        lineSeparator.accessibilityIdentifier = Metrics.lineSeparatorIdentifier
        headerIconView.accessibilityIdentifier = Metrics.headerIconViewIdentifier(commentType: viewModel.outputs.commentType)
    }
}

fileprivate extension OWCommentCreationFloatingKeyboardView {
    func setupViews() {
        self.clipsToBounds = false
        mainContainer.clipsToBounds = false
        self.useAsThemeStyleInjector()
        self.backgroundColor = .clear

        self.addSubviews(mainContainer)
        mainContainer.OWSnp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalToSuperviewSafeArea()
        }

        mainContainer.addSubview(closeButton)
        closeButton.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        mainContainer.addSubview(footerView)
        footerView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(mainContainer.OWSnp.bottom)
            make.top.greaterThanOrEqualToSuperview()
        }

        switch viewModel.outputs.commentType {
        case .comment:
            footerView.addSubview(lineSeparator)
        case .edit, .replyToComment:
            headerView.addSubview(lineSeparator)
            mainContainer.addSubview(headerView)
            mainContainer.bringSubviewToFront(footerView)
            headerView.OWSnp.makeConstraints { make in
                make.bottom.equalTo(footerView.OWSnp.top).inset(Metrics.headerHeight)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(Metrics.headerHeight)
                make.top.greaterThanOrEqualToSuperview()
            }
        }

        lineSeparator.OWSnp.makeConstraints { make in
            make.leading.top.trailing.equalToSuperview()
            make.height.equalTo(1)
        }

        footerView.addSubview(textViewObject)
        footerView.addSubview(userAvatarView)

        let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
        let isLandscape = currentOrientation == .landscape

        userAvatarView.OWSnp.makeConstraints { make in
            make.leading.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.leadingLandscapeMargin : Metrics.userAvatarLeadingPadding)
            make.bottom.equalTo(textViewObject.OWSnp.bottom)
            make.size.equalTo(Metrics.userAvatarSize)
        }

        footerView.addSubview(ctaButton)
        ctaButton.OWSnp.makeConstraints { make in
            make.leading.equalTo(textViewObject.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.trailing.equalToSuperviewSafeArea().inset(-Metrics.ctaButtonSize + (isLandscape ? Metrics.trailingLandscapeMargin : Metrics.ctaButtonHorizontalPadding))
            make.size.equalTo(Metrics.ctaButtonSize)
            make.bottom.equalTo(textViewObject.OWSnp.bottom)
        }

        textViewObject.OWSnp.makeConstraints { make in
            make.leading.equalTo(userAvatarView.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
            make.top.equalToSuperview().inset(OWCommentCreationEntryView.TextViewMetrics.textViewTopPadding)
            make.bottom.equalToSuperview().inset(OWCommentCreationEntryView.TextViewMetrics.textViewBottomPadding)
        }

        if let toolbar = toolbar {
            mainContainer.addSubview(toolbar)
            toolbar.OWSnp.makeConstraints { make in
                toolbarBottomConstraint = make.bottom.equalTo(mainContainer.OWSnp.bottom).constraint
                make.top.equalTo(textViewObject.OWSnp.bottom)
                make.leading.trailing.equalToSuperview()
            }
            updateToolbarConstraints(hidden: true)
        }

        mainContainer.addSubview(underFooterView)
        underFooterView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(mainContainer.OWSnp.bottom)
            make.height.equalTo(Metrics.underFooterHeight)
        }
    }

    func updateToolbarConstraints(hidden: Bool) {
        if let toolbar = toolbar {
            footerView.OWSnp.removeConstraints()
            if hidden {
                toolbarBottomConstraint?.deactivate()
                footerView.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(mainContainer.OWSnp.bottom)
                }
            } else {
                toolbarBottomConstraint?.activate()
                footerView.OWSnp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.bottom.equalTo(toolbar.OWSnp.top)
                }
            }
        }
    }

    var toastBottomPadding: CGFloat {
        let toolbarHeight = self.toolbar?.frame.size.height ?? 0
        let footerHeight = self.footerView.frame.size.height
        let headerHeight = self.headerView.frame.size.height
        return toolbarHeight + footerHeight + headerHeight + Metrics.errorToastBottomPadding
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        viewModel.outputs.displayToastCalled
            .subscribe(onNext: { [weak self] combinedData in
                guard let self = self else { return }
                var requiredData = combinedData.presentData.data
                requiredData.bottomPadding = self.toastBottomPadding
                let completions: [OWToastCompletion: PublishSubject<Void>?] = [.action: combinedData.actionCompletion, .dismiss: self.viewModel.inputs.dismissToast]
                self.mainContainer.presentToast(requiredData: requiredData, completions: completions, disposeBag: disposeBag)
                if let toolbar = self.toolbar {
                    self.mainContainer.bringSubviewToFront(toolbar)
                }
                self.mainContainer.bringSubviewToFront(self.footerView)
                self.mainContainer.bringSubviewToFront(self.headerView)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.hideToast
            .subscribe(onNext: { [weak self] in
                self?.mainContainer.dismissToast()
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.headerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.headerIconView.tintColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.headerTitleLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.footerView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.underFooterView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.headerCloseButton.image(UIImage(spNamed: Metrics.closeCrossIcon, supportDarkMode: true), state: .normal)
                self.toolbar?.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.lineSeparator.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        headerCloseButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.headerView.OWSnp.updateConstraints { make in
                    make.bottom.equalTo(self.footerView.OWSnp.top).inset(Metrics.headerHeight)
                }
                UIView.animate(withDuration: Metrics.closeHeaderDuration) { [weak self] in
                    guard let self = self else { return }
                    self.mainContainer.layoutIfNeeded()
                } completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.footerView.addSubview(lineSeparator)
                    self.lineSeparator.OWSnp.makeConstraints { make in
                        make.leading.top.trailing.equalToSuperview()
                        make.height.equalTo(1)
                    }
                }
            })
            .disposed(by: disposeBag)

        headerCloseButton.rx.tap
            .bind(to: viewModel.inputs.resetTypeToNewCommentChange)
            .disposed(by: disposeBag)

        let postedOrClosedObservable = Observable.merge(closeButton.rx.tap.asObservable(), viewModel.outputs.closedWithDelay.asObservable())
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] _ -> Observable<Void> in
                guard let self = self else { return .empty() }
                if self.toolbar != nil {
                    self.updateToolbarConstraints(hidden: true)
                    UIView.animate(withDuration: Metrics.toolbarAnimationSecondsDuration) { [weak self] in
                        guard let self = self else { return }
                        self.mainContainer.layoutIfNeeded()
                    }
                    return Observable.just(()).delay(.milliseconds(Metrics.delayKeyboard), scheduler: MainScheduler.instance)
                }
                return Observable.just(())
            })
            .share()

        postedOrClosedObservable
            .bind(to: viewModel.outputs.textViewVM.inputs.resignFirstResponderCall)
            .disposed(by: disposeBag)

        Observable.merge(closeButton.rx.tap.asObservable(), viewModel.outputs.closedWithDelay.asObservable())
            .observe(on: MainScheduler.instance)
            .delay(.milliseconds(toolbar == nil ? 0 : Metrics.toolbarAnimationMilisecondsDuration), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.outputs.textBeforeClosedChanged)
            .bind(to: viewModel.inputs.closeInstantly)
            .disposed(by: disposeBag)

        viewModel.outputs.ctaButtonLoading
            .bind(to: ctaButton.rx.isLoading)
            .disposed(by: disposeBag)

        viewModel.outputs.closedWithDelay
            .observe(on: MainScheduler.instance)
            .delay(.milliseconds(toolbar == nil ? 0 : Metrics.toolbarAnimationMilisecondsDuration), scheduler: MainScheduler.instance)
            .withLatestFrom(viewModel.outputs.textBeforeClosedChanged)
            .bind(to: viewModel.inputs.closeInstantly)
            .disposed(by: disposeBag)

        ctaButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.inputs.ctaTap.onNext()
            })
            .disposed(by: disposeBag)

        viewModel.outputs.ctaEnabled
            .bind(to: ctaButton.rx.isEnabled)
            .disposed(by: disposeBag)

        // Handle orientation change
        OWSharedServicesProvider.shared.orientationService()
            .orientation
            // Skip first orientation subscription's onNext .share(replay: 1)
            // since we dont want the initial UI to be messed up before the keyboard
            // shows with animation and puts objects into their final position.
            .skip(1)
            .subscribe(onNext: { [weak self] currentOrientation in
                guard let self = self else { return }
                let isLandscape = currentOrientation == .landscape

                self.headerIconView.OWSnp.updateConstraints { make in
                    make.leading.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.leadingLandscapeMargin : Metrics.headerIconLeadingPadding)
                }

                self.headerCloseButton.OWSnp.updateConstraints { make in
                    make.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.trailingLandscapeMargin : Metrics.headerTrailingPadding)
                }

                self.userAvatarView.OWSnp.updateConstraints { make in
                    make.leading.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.leadingLandscapeMargin : Metrics.userAvatarLeadingPadding)
                }

                self.ctaButton.OWSnp.updateConstraints { make in
                    make.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.trailingLandscapeMargin : Metrics.ctaButtonHorizontalPadding)
                }
            })
            .disposed(by: disposeBag)

        // keyboard will show
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .withLatestFrom(viewModel.outputs.textBeforeClosedChanged) { ($0, $1) }
            .subscribe(onNext: { [weak self] (notification, textBeforeClosed) in
                guard
                   let self = self,
                   let expandedKeyboardHeight = notification.keyboardSize?.height,
                   let animationDuration = notification.keyboardAnimationDuration
                else { return }

                let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
                let isLandscape = currentOrientation == .landscape

                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.textViewObject.layer.borderColor = OWColorPalette.shared.color(type: .brandColor,
                                                                                        themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor
                    self.ctaButton.alpha(1)
                    self.ctaButton.OWSnp.updateConstraints { make in
                        make.leading.equalTo(self.textViewObject.OWSnp.trailing).offset(Metrics.ctaButtonHorizontalPadding)
                        make.trailing.equalToSuperviewSafeArea().inset(Metrics.ctaButtonHorizontalPadding)
                    }
                    if case .comment = self.viewModel.outputs.commentType {} else {
                        self.headerView.OWSnp.updateConstraints { make in
                            make.bottom.equalTo(self.footerView.OWSnp.top).inset(0)
                        }
                        self.headerView.layoutIfNeeded()
                    }
                    self.footerView.layoutIfNeeded()
                }

                // Set the initial text to the textView in this animation stage
                if self.keyboardWasHidden {
                    if self.viewModel.outputs.initialText.isEmpty {
                        self.viewModel.outputs.textViewVM
                            .inputs.textExternalChange.onNext(textBeforeClosed)
                    } else {
                        self.viewModel.outputs.textViewVM
                            .inputs.textExternalChange.onNext(self.viewModel.outputs.initialText)
                        self.viewModel.inputs.initialTextUsed.onNext()
                    }
                }

                let bottomPadding = self.window?.safeAreaInsets.bottom ?? 0

                self.mainContainer.OWSnp.updateConstraints { make in
                    make.bottom.equalToSuperviewSafeArea().offset(-(expandedKeyboardHeight - bottomPadding))
                }
                self.ctaButton.OWSnp.updateConstraints { make in
                    make.trailing.equalToSuperviewSafeArea().inset(isLandscape ? Metrics.trailingLandscapeMargin : Metrics.ctaButtonHorizontalPadding)
                }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    if self.viewModel.outputs.viewableMode == .independent {
                        self.backgroundColor = Metrics.floatingBackgroungColor
                    }
                    self.mainContainer.layoutIfNeeded()
                }
                self.keyboardWasHidden = false
            })
            .disposed(by: disposeBag)

        // keyboard will hide
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .withLatestFrom(viewModel.outputs.textViewVM.outputs.textViewText) { ($0, $1) }
            .withLatestFrom(viewModel.outputs.ctaButtonLoading) { ($0.0, $0.1, $1) }
            .subscribe(onNext: { [weak self] (notification, textViewText, isSendingComment) in
                guard
                    let self = self,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }

                self.viewModel.inputs.textBeforeClosedChange.onNext(isSendingComment ? "" : textViewText)
                self.viewModel.outputs.textViewVM.inputs.textExternalChange.onNext("")

                let currentOrientation = OWSharedServicesProvider.shared.orientationService().currentOrientation
                let isLandscape = currentOrientation == .landscape

                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.textViewObject.layer.borderColor = OWColorPalette.shared.color(type: .borderColor2,
                                                                                        themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle).cgColor
                    self.ctaButton.alpha(0)
                    self.ctaButton.OWSnp.updateConstraints { make in
                        make.leading.equalTo(self.textViewObject.OWSnp.trailing).offset(Metrics.textViewHorizontalPadding)
                        make.trailing.equalToSuperviewSafeArea().inset(-Metrics.ctaButtonSize + (isLandscape ? Metrics.trailingLandscapeMargin : Metrics.ctaButtonHorizontalPadding))
                    }
                    if case .comment = self.viewModel.outputs.commentType {} else {
                        self.headerView.OWSnp.updateConstraints { make in
                            make.bottom.equalTo(self.footerView.OWSnp.top).inset(Metrics.headerHeight)
                        }
                        self.headerView.layoutIfNeeded()
                    }
                    self.footerView.layoutIfNeeded()

                    self.mainContainer.OWSnp.updateConstraints { make in
                        make.bottom.equalToSuperviewSafeArea()
                    }
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        guard let self = self else { return }
                        self.backgroundColor = .clear
                        self.mainContainer.layoutIfNeeded()
                    } completion: { [weak self] finished in
                        guard let self = self else { return }
                        if finished && self.viewModel.outputs.viewableMode == .independent {
                            self.firstLayoutSubviewsDone = false
                        }
                    }
                }
                self.keyboardWasHidden = true
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func updateCustomUI() {
        self.viewModel.inputs.triggerCustomizeSubmitButtonUI.onNext(ctaButton)
    }
}

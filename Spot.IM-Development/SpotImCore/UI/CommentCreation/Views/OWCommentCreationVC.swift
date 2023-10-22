//
//  OWCommentCreationVC.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate struct Metrics {
        static let floatingBackgroungColor = UIColor.black.withAlphaComponent(0.3)
        static let navBarTitleFadeDuration = 0.3
        static let floatingOverNavBarOffset: CGFloat = -100
    }

    fileprivate let viewModel: OWCommentCreationViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var commentCreationView: OWCommentCreationView = {
        let commentCreationView = OWCommentCreationView(viewModel: viewModel.outputs.commentCreationViewVM)
        return commentCreationView
    }()

    fileprivate lazy var footerSafeAreaView: UIView = {
        return UIView(frame: .zero)
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    lazy var floatingNavigationBarOverlayButton = {
        return UIButton()
            .backgroundColor(Metrics.floatingBackgroungColor)
            .alpha(0)
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var navigationBarHidden = true
        if case .floatingKeyboard = viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            navigationBarHidden = false
            // Fix navigation title flicker
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 0
            fadeTextAnimation.type = .fade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fixNavigationTitleFlicker")

            // This code is here on purpose and not in setupViews since we need to do this also going
            // back from extra screens that can be pushed after this VC like for example authentication screen
            self.navigationController?.navigationBar.addSubviews(floatingNavigationBarOverlayButton)
            floatingNavigationBarOverlayButton.OWSnp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
                make.top.equalToSuperview().offset(Metrics.floatingOverNavBarOffset)
            }
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        navigationController?.setNavigationBarHidden(navigationBarHidden, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)

        if case .floatingKeyboard = viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            // Fix navigation title flicker
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = Metrics.navBarTitleFadeDuration
            fadeTextAnimation.type = .fade
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fixNavigationTitleFlicker")
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        floatingNavigationBarOverlayButton.removeFromSuperview()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWManager.manager.helpers.orientationEnforcement.interfaceOrientationMask
    }
}

fileprivate extension OWCommentCreationVC {
    func setupViews() {
        let backgroundColor: UIColor = {
            switch viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            case .regular, .light:
                return OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)
            case .floatingKeyboard:
                return Metrics.floatingBackgroungColor
            }
        }()
        self.view.backgroundColor = backgroundColor

        view.addSubview(commentCreationView)
        commentCreationView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }

        view.addSubview(footerSafeAreaView)
        footerSafeAreaView.OWSnp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.OWSnp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                let backgroundColor: UIColor = {
                    switch self.viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                    case .regular, .light:
                        return OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                    case .floatingKeyboard:
                        return Metrics.floatingBackgroungColor
                    }
                }()
                self.view.backgroundColor = backgroundColor
                self.footerSafeAreaView.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        if case .floatingKeyboard = viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
            floatingNavigationBarOverlayButton.rx.tap
                .bind(to: viewModel.outputs.commentCreationViewVM.outputs.commentCreationFloatingKeyboardViewVm.inputs.closeWithDelay)
                .disposed(by: disposeBag)
        }

        self.setupStatusBarStyleUpdaterObservers()

        // keyboard will show
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let expandedKeyboardHeight = notification.keyboardSize?.height,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                switch self.viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                case .regular, .light:
                    let bottomPadding: CGFloat
                    bottomPadding = self.tabBarController?.tabBar.frame.height ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
                    self.commentCreationView.OWSnp.updateConstraints { make in
                        make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-(expandedKeyboardHeight - bottomPadding))
                    }
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        guard let self = self else { return }
                        self.view.layoutIfNeeded()
                    }
                case .floatingKeyboard:
                    // floatingKeyboard style handles it's own constraints
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        guard let self = self else { return }
                        self.view.backgroundColor = Metrics.floatingBackgroungColor
                        self.floatingNavigationBarOverlayButton.alpha = 1
                        self.view.layoutIfNeeded()
                    }
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
                switch self.viewModel.outputs.commentCreationViewVM.outputs.commentCreationStyle {
                case .regular, .light:
                    self.commentCreationView.OWSnp.updateConstraints { make in
                        make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                    }
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        guard let self = self else { return }
                        self.view.layoutIfNeeded()
                    }
                case .floatingKeyboard:
                    // floatingKeyboard style handles it's own constraints
                    UIView.animate(withDuration: animationDuration) { [weak self] in
                        guard let self = self else { return }
                        self.view.backgroundColor = .clear
                        self.floatingNavigationBarOverlayButton.alpha = 0
                        self.view.layoutIfNeeded()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

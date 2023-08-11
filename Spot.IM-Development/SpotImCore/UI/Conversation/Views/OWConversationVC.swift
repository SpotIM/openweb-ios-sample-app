//
//  OWConversationVC.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate struct Metrics {
        static let closeButtonImageName: String = "closeButton"
        static let animationTimeForLargeTitle: Double = 0.15
    }

    fileprivate let viewModel: OWConversationViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var conversationView: OWConversationView = {
        return OWConversationView(viewModel: viewModel.outputs.conversationViewVM)
    }()

    fileprivate lazy var closeButton: UIButton = {
        let closeButton = UIButton()
            .image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
            .horizontalAlignment(.left)

        closeButton.addTarget(self, action: #selector(self.closeConversationTapped(_:)), for: .touchUpInside)
        return closeButton
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWConversationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupUI()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.inputs.viewDidLoad.onNext()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }
}

fileprivate extension OWConversationVC {
    func setupUI() {
        self.title = viewModel.outputs.title
        self.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(conversationView)
        conversationView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        addingCloseButtonIfNeeded()
        setupNavControllerUI()
    }

    func addingCloseButtonIfNeeded() {
        if viewModel.outputs.shouldShowCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        }
    }

    func setupNavControllerUI(_ style: OWThemeStyle = OWSharedServicesProvider.shared.themeStyleService().currentStyle) {

        guard let navController = self.navigationController else { return }

        if viewModel.outputs.shouldCustomizeNavigationBar {

            navController.navigationBar.prefersLargeTitles = true

            let navigationBarBackgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: style)
            navController.navigationBar.tintColor = OWColorPalette.shared.color(type: .textColor1, themeStyle: style)

            // Setup Title
            let navigationTitleTextAttributes = [
                NSAttributedString.Key.font: OWFontBook.shared.font(typography: .titleSmall),
                NSAttributedString.Key.foregroundColor: OWColorPalette.shared.color(type: .textColor1, themeStyle: style)
            ]

            if #available(iOS 13.0, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = navigationBarBackgroundColor
                appearance.titleTextAttributes = navigationTitleTextAttributes

                // Setup Back button
                let backButtonAppearance = UIBarButtonItemAppearance(style: .plain)
                backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
                appearance.backButtonAppearance = backButtonAppearance

                navController.navigationBar.standardAppearance = appearance
                navController.navigationBar.scrollEdgeAppearance = navController.navigationBar.standardAppearance
            } else {
                navController.navigationBar.backgroundColor = navigationBarBackgroundColor
                navController.navigationBar.titleTextAttributes = navigationTitleTextAttributes
            }
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: currentStyle == .dark), state: .normal)
                self.setupNavControllerUI(currentStyle)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        self.setupStatusBarStyleUpdaterObservers()

        let conversationOffset = viewModel.outputs.conversationViewVM
            .outputs.conversationOffset
            .share()

        let shouldShouldChangeToLargeTitleDisplay = conversationOffset
            .filter { $0.y <= 0 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { !$0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.always }

        let shouldShouldChangeToRegularTitleDisplay = conversationOffset
            .filter { $0.y > 0 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { $0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.never }

        Observable.merge(shouldShouldChangeToLargeTitleDisplay, shouldShouldChangeToRegularTitleDisplay)
            .subscribe(onNext: { [weak self] displayMode in
                guard let self = self else { return }

                let isLargeTitleGoingToBeDisplay = displayMode == .always
                self.viewModel.inputs.changeIsLargeTitleDisplay.onNext(isLargeTitleGoingToBeDisplay)
                self.navigationItem.largeTitleDisplayMode = displayMode
                UIView.animate(withDuration: Metrics.animationTimeForLargeTitle, animations: {
                    self.navigationController?.navigationBar.layoutIfNeeded()
                })
            })
            .disposed(by: disposeBag)
    }

    func updateCustomUI() {
        viewModel.inputs.triggerCustomizeNavigationItemUI.onNext(navigationItem)
        if let navigationBar = navigationController?.navigationBar {
            viewModel.inputs.triggerCustomizeNavigationBarUI.onNext(navigationBar)
        }
    }

    @objc func closeConversationTapped(_ sender: UIBarButtonItem) {
        viewModel.inputs.closeConversationTapped.onNext()
    }
}

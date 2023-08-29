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
        setupUI()
        setupObservers()
    }

    override func loadView() {
        super.loadView()
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
        let navControllerCustomizer = OWSharedServicesProvider.shared.navigationControllerCustomizer()
        if navControllerCustomizer.isLargeTitlesEnabled() {
            self.navigationItem.largeTitleDisplayMode = .always
        }

        view.addSubview(conversationView)
        conversationView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }

        addingCloseButtonIfNeeded()
    }

    func addingCloseButtonIfNeeded() {
        if viewModel.outputs.shouldShowCloseButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: currentStyle == .dark), state: .normal)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        self.setupStatusBarStyleUpdaterObservers()

        // Large titles related observables
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
                let navControllerCustomizer = OWSharedServicesProvider.shared.navigationControllerCustomizer()
                guard let self = self, navControllerCustomizer.isLargeTitlesEnabled() else { return }

                let isLargeTitleGoingToBeDisplay = displayMode == .always
                self.viewModel.inputs.changeIsLargeTitleDisplay.onNext(isLargeTitleGoingToBeDisplay)
                self.navigationItem.largeTitleDisplayMode = displayMode
                UIView.animate(withDuration: OWNavigationControllerCustomizer.Metrics.animationTimeForLargeTitle, animations: {
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

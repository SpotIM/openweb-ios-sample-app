//
//  OWConversationVC.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWConversationVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    private struct Metrics {
        static let closeButtonImageName: String = "closeButton"
    }

    private let viewModel: OWConversationViewModeling
    let disposeBag = DisposeBag()

    private lazy var conversationView: OWConversationView = {
        return OWConversationView(viewModel: viewModel.outputs.conversationViewVM)
    }()

    private lazy var closeButton: UIButton = {
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

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWSharedServicesProvider.shared.orientationService().interfaceOrientationMask
    }
}

private extension OWConversationVC {
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
        Observable.combineLatest(OWSharedServicesProvider.shared.themeStyleService().style,
                                 OWSharedServicesProvider.shared.orientationService().orientation)
            .subscribe(onNext: { [weak self] currentStyle, currentOrientation in
                guard let self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: currentOrientation == .landscape ? .backgroundColor6 : .backgroundColor2, themeStyle: currentStyle)
                self.closeButton.image(UIImage(spNamed: Metrics.closeButtonImageName, supportDarkMode: true), state: .normal)
                self.updateCustomUI()
            })
            .disposed(by: disposeBag)

        self.setupStatusBarStyleUpdaterObservers()

        // Large titles related observables
        let conversationOffset = viewModel.outputs.conversationViewVM
            .outputs.conversationOffset
            .share()

        let conversationContentSizeHeight = viewModel.outputs.conversationViewVM
            .outputs.tableViewContentSizeHeightChanged

        let conversationHeight = viewModel.outputs.conversationViewVM
            .outputs.tableViewHeightChanged

        let isContentBiggerThanTableView = conversationContentSizeHeight
            .withLatestFrom(conversationHeight) { ($0, $1) }
            .map { [weak self] in
                $0 > $1 + (self?.navigationController?.navigationBar.frame.height ?? 0)
            }
            .share()

        let shouldShouldChangeToLargeTitleDisplay = conversationOffset
            .withLatestFrom(isContentBiggerThanTableView) { ($0, $1) }
            .filter { $0.y <= 0 && $1 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { !$0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.always }

        let shouldShouldChangeToRegularTitleDisplay = conversationOffset
            .withLatestFrom(isContentBiggerThanTableView) { ($0, $1) }
            .filter { $0.y > 0 && $1 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { $0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.never }

        Observable.merge(shouldShouldChangeToLargeTitleDisplay, shouldShouldChangeToRegularTitleDisplay)
            .subscribe(onNext: { [weak self] displayMode in
                let navControllerCustomizer = OWSharedServicesProvider.shared.navigationControllerCustomizer()
                guard let self, navControllerCustomizer.isLargeTitlesEnabled() else { return }

                let isLargeTitleGoingToBeDisplay = displayMode == .always
                self.viewModel.inputs.changeIsLargeTitleDisplay.onNext(isLargeTitleGoingToBeDisplay)
                OWScheduler.runOnMainThreadIfNeeded {
                    self.navigationItem.largeTitleDisplayMode = displayMode
                    UIView.animate(withDuration: OWNavigationControllerCustomizer.Metrics.animationTimeForLargeTitle, animations: {
                        self.navigationController?.navigationBar.layoutIfNeeded()
                    })
                }
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

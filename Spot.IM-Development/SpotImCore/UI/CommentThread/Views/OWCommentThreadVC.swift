//
//  OWCommentThreadVC.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentThreadVC: UIViewController, OWStatusBarStyleUpdaterProtocol {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWCommentThreadViewModeling
    let disposeBag = DisposeBag()

    fileprivate lazy var commentThreadView: OWCommentThreadView = {
        let commentThreadView = OWCommentThreadView(viewModel: viewModel.outputs.commentThreadViewVM)
        return commentThreadView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentThreadViewModeling) {
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return OWSharedServicesProvider.shared.statusBarStyleService().currentStyle
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return OWSharedServicesProvider.shared.orientationService().interfaceOrientationMask
    }
}

fileprivate extension OWCommentThreadVC {
    func setupViews() {
        self.title = viewModel.outputs.title
        let navControllerCustomizer = OWSharedServicesProvider.shared.navigationControllerCustomizer()
        if navControllerCustomizer.isLargeTitlesEnabled() {
            self.navigationItem.largeTitleDisplayMode = .always
        }

        view.addSubview(commentThreadView)
        commentThreadView.OWSnp.makeConstraints { make in
            make.top.equalToSuperviewSafeArea()
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func setupObservers() {
        self.setupStatusBarStyleUpdaterObservers()

        // Large titles related observables
        let threadOffset = viewModel.outputs.commentThreadViewVM
            .outputs.threadOffset
            .share()

        let shouldShouldChangeToLargeTitleDisplay = threadOffset
            .filter { $0.y <= 0 }
            .withLatestFrom(viewModel.outputs.isLargeTitleDisplay)
            .filter { !$0 }
            .voidify()
            .map { return UINavigationItem.LargeTitleDisplayMode.always }

        let shouldShouldChangeToRegularTitleDisplay = threadOffset
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

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}

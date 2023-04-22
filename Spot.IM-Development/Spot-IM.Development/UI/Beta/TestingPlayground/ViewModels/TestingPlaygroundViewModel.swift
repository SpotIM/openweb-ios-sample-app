//
//  TestingPlaygroundViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if BETA

protocol TestingPlaygroundViewModelingInputs {
    var playgroundPushModeTapped: PublishSubject<Void> { get }
    var playgroundPresentModeTapped: PublishSubject<Void> { get }
    var playgroundIndependentModeTapped: PublishSubject<Void> { get }
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol TestingPlaygroundViewModelingOutputs {
    var title: String { get }
    var showError: Observable<String> { get }
    var openTestingPlaygroundIndependent: Observable<SDKConversationDataModel> { get }
}

protocol TestingPlaygroundViewModeling {
    var inputs: TestingPlaygroundViewModelingInputs { get }
    var outputs: TestingPlaygroundViewModelingOutputs { get }
}

class TestingPlaygroundViewModel: TestingPlaygroundViewModeling,
                                TestingPlaygroundViewModelingOutputs,
                                TestingPlaygroundViewModelingInputs {
    var inputs: TestingPlaygroundViewModelingInputs { return self }
    var outputs: TestingPlaygroundViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    fileprivate weak var navController: UINavigationController?
    fileprivate weak var presentationalVC: UIViewController?

    let playgroundPushModeTapped = PublishSubject<Void>()
    let playgroundPresentModeTapped = PublishSubject<Void>()
    let playgroundIndependentModeTapped = PublishSubject<Void>()

    var openTestingPlaygroundIndependent: Observable<SDKConversationDataModel> {
        return playgroundIndependentModeTapped
            .asObservable()
            .map { [weak self] _ -> SDKConversationDataModel? in
                guard let self = self else { return nil }
                return self.dataModel
            }
            .unwrap()
    }

    fileprivate let _showError = PublishSubject<String>()
    var showError: Observable<String> {
        return _showError
            .asObservable()
    }

    var presentStyle: OWModalPresentationStyle {
        // swiftlint:disable line_length
        return OWModalPresentationStyle.presentationStyle(fromIndex: UserDefaultsProvider.shared.get(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.defaultIndex))
        // swiftlint:enable line_length
    }

    lazy var title: String = {
        return NSLocalizedString("TestingPlayground", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }
}

fileprivate extension TestingPlaygroundViewModel {

    func setupObservers() {

        let playgroundPushModeObservable = playgroundPushModeTapped
            .asObservable()
            .map { PresentationalModeCompact.push }

        let playgroundPresentModeObservable = playgroundPresentModeTapped
            .asObservable()
            .map { [weak self] _ -> PresentationalModeCompact? in
                guard let self = self else { return nil }
                return PresentationalModeCompact.present(style: self.presentStyle)
            }
            .unwrap()

        // Testing playground - Flows
        Observable.merge(playgroundPushModeObservable, playgroundPresentModeObservable)
            .subscribe(onNext: { [weak self] mode in
                guard let self = self else { return }
                let postId = self.dataModel.postId

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.testingPlayground(postId: postId,
                                        presentationalMode: presentationalMode,
                                        additionalSettings: nil,
                                        callbacks: nil,
                                        completion: { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.testingPlayground error: \(message)")
                        self._showError.onNext(message)
                    }
                })
            })
            .disposed(by: disposeBag)
    }

    func presentationalMode(fromCompactMode mode: PresentationalModeCompact) -> OWPresentationalMode? {
        guard let navController = self.navController,
              let presentationalVC = self.presentationalVC else { return nil }

        switch mode {
        case .present(let style):
            return OWPresentationalMode.present(viewController: presentationalVC, style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: navController)
        }
    }
}

#endif

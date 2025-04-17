//
//  TestingPlaygroundViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import Combine
import OpenWebSDK

#if BETA

protocol TestingPlaygroundViewModelingInputs {
    var playgroundPushModeTapped: PassthroughSubject<Void, Never> { get }
    var playgroundPresentModeTapped: PassthroughSubject<Void, Never> { get }
    var playgroundIndependentModeTapped: PassthroughSubject<Void, Never> { get }
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol TestingPlaygroundViewModelingOutputs {
    var title: String { get }
    var showError: AnyPublisher<String, Never> { get }
    var openTestingPlaygroundIndependent: AnyPublisher<SDKConversationDataModel, Never> { get }
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

    private let dataModel: SDKConversationDataModel

    private var cancellables = Set<AnyCancellable>()

    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?

    let playgroundPushModeTapped = PassthroughSubject<Void, Never>()
    let playgroundPresentModeTapped = PassthroughSubject<Void, Never>()
    let playgroundIndependentModeTapped = PassthroughSubject<Void, Never>()

    var openTestingPlaygroundIndependent: AnyPublisher<SDKConversationDataModel, Never> {
        return playgroundIndependentModeTapped
            .map { [weak self] _ -> SDKConversationDataModel? in
                guard let self else { return nil }
                return self.dataModel
            }
            .unwrap()
    }

    private let _showError = PassthroughSubject<String, Never>()
    var showError: AnyPublisher<String, Never> {
        return _showError
            .eraseToAnyPublisher()
    }

    var present: OWModalPresentationStyle {
        return OWModalPresentationStyle.presentationStyle(fromIndex: UserDefaultsProvider.shared.get(key: .modalStyleIndex, defaultValue: OWModalPresentationStyle.default.index))
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

private extension TestingPlaygroundViewModel {

    func setupObservers() {

        let playgroundPushModeObservable = playgroundPushModeTapped
            .map { PresentationalModeCompact.push }

        let playgroundPresentModeObservable = playgroundPresentModeTapped
            .map { [weak self] _ -> PresentationalModeCompact? in
                guard let self else { return nil }
                return PresentationalModeCompact.present(style: self.present)
            }
            .unwrap()

        // Testing playground - Flows
        Publishers.Merge(playgroundPushModeObservable, playgroundPresentModeObservable)
            .sink(receiveValue: { [weak self] mode in
                guard let self else { return }
                let postId = self.dataModel.postId

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                flows.testingPlayground(postId: postId,
                                        presentationalMode: presentationalMode,
                                        additionalSettings: OWTestingPlaygroundSettings(),
                                        callbacks: nil,
                                        completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success:
                        // All good
                        break
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.testingPlayground error: \(message)")
                        self._showError.send(message)
                    }
                })
            })
            .store(in: &cancellables)
    }

    func presentationalMode(fromCompactMode mode: PresentationalModeCompact) -> OWPresentationalMode? {
        guard let navController = self.navController,
              let presentationalVC else { return nil }

        switch mode {
        case .present(let style):
            return OWPresentationalMode.present(viewController: presentationalVC, style: style)
        case .push:
            return OWPresentationalMode.push(navigationController: navController)
        }
    }
}

#endif

//
//  PreconversationCellViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 18/12/2024.
//

import Foundation
import RxSwift
import OpenWebSDK

protocol PreconversationCellViewModelingInput {
    func setNavigationController(_ navController: UINavigationController?)
    func setPresentationalVC(_ viewController: UIViewController)
}

protocol PreconversationCellViewModelingOutput {
    var showPreConversation: Observable<UIView?> { get }
    var adSizeChanged: Observable<Void> { get }
    var preConversationHorizontalMargin: CGFloat { get }

}

protocol PreconversationCellViewModeling {
    var inputs: PreconversationCellViewModelingInput { get }
    var outputs: PreconversationCellViewModelingOutput { get }
}

public final class PreconversationCellViewModel: PreconversationCellViewModeling,
                                                 PreconversationCellViewModelingOutput,
                                                 PreconversationCellViewModelingInput {
    var inputs: PreconversationCellViewModelingInput { self }
    var outputs: PreconversationCellViewModelingOutput { self }

    private struct Metrics {
        static let preConversationCompactHorizontalMargin: CGFloat = 16.0
    }
    private let disposeBag = DisposeBag()

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let commonCreatorService: CommonCreatorServicing

    private weak var navController: UINavigationController?
    private weak var presentationalVC: UIViewController?

    func setNavigationController(_ navController: UINavigationController?) {
        self.navController = navController
    }

    func setPresentationalVC(_ viewController: UIViewController) {
        presentationalVC = viewController
    }

    private let _showPreConversation = BehaviorSubject<UIView?>(value: nil)
    var showPreConversation: Observable<UIView?> {
        return _showPreConversation
            .asObservable()
    }

    private let _adSizeChanged = PublishSubject<Void>()
    var adSizeChanged: Observable<Void> {
        return _adSizeChanged
            .asObservable()
    }

    private let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    private var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    lazy var loggerEnabled: Observable<Bool> = {
        return userDefaultsProvider.values(key: .flowsLoggerEnabled, defaultValue: false)
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: "Flows Logger")
    }()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         actionSettings: SDKUIFlowActionSettings,
         commonCreatorService: CommonCreatorServicing = CommonCreatorService()) {
        self.userDefaultsProvider = userDefaultsProvider
        self.commonCreatorService = commonCreatorService
        _actionSettings.onNext(actionSettings)
        setupObservers()
    }

    var preConversationHorizontalMargin: CGFloat {
        let preConversationStyle = userDefaultsProvider.get(key: .preConversationStyle, defaultValue: OWPreConversationStyle.default)
        let margin = preConversationStyle == OWPreConversationStyle.compact ? Metrics.preConversationCompactHorizontalMargin : 0.0
        return margin
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

private extension PreconversationCellViewModel {
    func setupObservers() {
        actionSettings
            .map { settings -> (PresentationalModeCompact, String)? in
                if case .preConversation(let mode) = settings.actionType {
                    return (mode, settings.postId)
                } else {
                    return nil
                }
            }
            .unwrap()
            // Small delay so the navigation controller will be set from the view controller
            .delay(.milliseconds(50), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInteractive))
            .withLatestFrom(loggerEnabled) { result, loggerEnabled -> (PresentationalModeCompact, String, Bool) in
                return (result.0, result.1, loggerEnabled)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] result in
                guard let self else { return }
                let mode = result.0
                let postId = result.1
                let loggerEnabled = result.2

                let manager = OpenWeb.manager
                let flows = manager.ui.flows

                let additionalSettings = self.commonCreatorService.additionalSettings()
                let article = self.commonCreatorService.mockArticle(for: manager.spotId)

                guard let presentationalMode = self.presentationalMode(fromCompactMode: mode) else { return }

                flows.preConversation(postId: postId,
                                      article: article,
                                      presentationalMode: presentationalMode,
                                      additionalSettings: additionalSettings,
                                      callbacks: actionCallbacks(loggerEnabled: loggerEnabled),
                                      completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let preConversationView):
                        self._showPreConversation.onNext(preConversationView)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.preConversation error: \(error)")
                    }
                })
            })
            .disposed(by: disposeBag)
    }

    func actionCallbacks(loggerEnabled: Bool) -> OWFlowActionsCallbacks? {
        return { [weak self] callbackType, sourceType, postId in
            guard let self else { return }

            switch callbackType {
            case .adSizeChanged:
                _adSizeChanged.onNext()
            default:
                guard loggerEnabled else { return }
                let log = "Received OWFlowActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                self.loggerViewModel.inputs.log(text: log)
            }

        }
    }
}

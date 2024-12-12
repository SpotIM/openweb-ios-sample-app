//
//  OWWebTabCoordinator.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 09/11/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

enum OWWebTabCoordinatorResult: OWCoordinatorResultProtocol {
    case loadedToScreen
    case popped

    var loadedToScreen: Bool {
        switch self {
        case .loadedToScreen:
            return true
        default:
            return false
        }
    }
}

class OWWebTabCoordinator: OWBaseCoordinator<OWWebTabCoordinatorResult> {

    private let router: OWRoutering?
    private let options: OWWebTabOptions
    private let viewActionsCallbacks: OWViewActionsCallbacks?
    private var viewableMode: OWViewableMode!
    private let servicesProvider: OWSharedServicesProviding
    private lazy var viewActionsService: OWViewActionsServicing = {
        return OWViewActionsService(viewActionsCallbacks: viewActionsCallbacks, viewSourceType: .webView)
    }()

    init(
        router: OWRoutering? = nil,
        options: OWWebTabOptions,
        viewActionsCallbacks: OWViewActionsCallbacks?,
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
    ) {
        self.router = router
        self.options = options
        self.viewActionsCallbacks = viewActionsCallbacks // TODO: handle actions callbacks?
        self.servicesProvider = servicesProvider
    }

    override func start(coordinatorData: OWCoordinatorData? = nil) -> Observable<OWWebTabCoordinatorResult> {
        guard let router else { return .empty() }
        viewableMode = .partOfFlow
        let webTabVM = OWWebTabViewModel(options: options,
                                            viewableMode: .partOfFlow)
        let webTabVC = OWWebTabVC(viewModel: webTabVM)

        let webTabVCPopped = PublishSubject<Void>()

        if router.isEmpty() {
            router.start()
            router.setRoot(webTabVC, animated: false, dismissCompletion: webTabVCPopped)
        } else {
            router.push(webTabVC,
                        pushStyle: .regular,
                        animated: true,
                        popCompletion: webTabVCPopped)
        }

        let partOfFlowPresentedWebClosedObservable = webTabVM.outputs
            .closeWebTab
            .do(onNext: { [weak self] _ in
                guard let self else { return }
                self.router?.pop(popStyle: .dismiss, animated: false)
            })

        let webVCPoppedObservable = Observable.merge(webTabVCPopped, partOfFlowPresentedWebClosedObservable)
            .map { OWWebTabCoordinatorResult.popped }
            .asObservable()

        let webVCLoadedToScreenObservable = webTabVM.outputs.screenLoaded
            .map { OWWebTabCoordinatorResult.loadedToScreen }
            .asObservable()

        // on delete account, show an alert and then route back to a guest state
        let accountDeletedObservable = webTabVM.webTabViewVM.outputs.javaScriptEvent
            .filter { $0 == OWOpenProfileData.deleteAccountEvent }
            .flatMap { _ -> Observable<Void> in
                return Observable.create { observer in
                    OWManager.manager.authentication.logout { result in
                        observer.onNext(())
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
            }
            .do(onNext: { [weak self] _ in
                if let postId = OWManager.manager.postId {
                    self?.servicesProvider.conversationUpdaterService().update(.refreshConversation, postId: postId)
                }
            })
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Void> in
                guard let self else { return .empty() }
                let okAction = OWRxPresenterAction(title: OWLocalize.string("OK"), type: OWEmptyMenu.ok)
                return servicesProvider.presenterService().showAlert(
                    title: OWLocalize.string("PrivacyDeleteAccountSuccessTitle"),
                    message: OWLocalize.string("PrivacyDeleteAccountSuccessSubtitle"),
                    actions: [okAction],
                    viewableMode: viewableMode
                )
                .map { action in }
            }
            .do(onNext: { [weak self] _ in
                self?.router?.pop(animated: true)
            })
            .map {
                return OWWebTabCoordinatorResult.popped
            }

        return Observable.merge(webVCPoppedObservable, webVCLoadedToScreenObservable, accountDeletedObservable)
    }

    override func showableComponent() -> Observable<OWShowable> {
        viewableMode = .independent
        let webTabViewVM: OWWebTabViewViewModeling = OWWebTabViewViewModel(
            options: options,
            viewableMode: viewableMode,
            javaScriptEvents: [OWOpenProfileData.deleteAccountEvent]
        )
        let webTabView = OWWebTabView(viewModel: webTabViewVM)
        setupViewActionsCallbacks(forViewModel: webTabViewVM)
        return .just(webTabView)
    }
}

private extension OWWebTabCoordinator {
    func setupViewActionsCallbacks(forViewModel viewModel: OWWebTabViewViewModeling) {
        let closeObservable = viewModel.outputs.closeTapped
            .voidify()
            .map { OWViewActionCallbackType.closeWebView }

        Observable.merge(closeObservable)
            .filter { _ in
                viewModel.outputs.viewableMode == .independent
            }
            .subscribe(onNext: { [weak self] viewAction in
                guard let self else { return }
                self.viewActionsService.append(viewAction: viewAction)
            })
            .disposed(by: disposeBag)
    }
}

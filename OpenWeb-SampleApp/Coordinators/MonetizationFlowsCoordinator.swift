//
//  MonetizationFlowsCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import RxSwift
import Combine
import OpenWebSDK

class MonetizationFlowsCoordinator: BaseCoordinator<Void> {

    private let router: Routering
    private var cancellables = Set<AnyCancellable>()

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationFlowsCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationFlowsViewModeling = MonetizationFlowsViewModel(postId: postId)
        let monetizationVC = MonetizationFlowsVC(viewModel: monetizationViewModel)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

private extension MonetizationFlowsCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationFlowsViewModeling) {
        // Bridge Combine publisher to RxSwift Observable (temporary)
        let openSingleAdObservable = Observable<OWPostId>.create { observer in
            let cancellable = viewModel.outputs.openSingleAdExample
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            observer.onError(error)
                        }
                    },
                    receiveValue: { postId in
                        observer.onNext(postId)
                    }
                )

            return Disposables.create {
                cancellable.cancel()
            }
        }

        openSingleAdObservable
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                let singleAdExampleViewModel = SingleAdExampleViewModel(postId: postId)
                let singleAdExampleVC = SingleAdExampleVC(viewModel: singleAdExampleViewModel)
                self.router.push(singleAdExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)

        // Bridge Combine publisher to RxSwift Observable (temporary)
        let openPreconversationWithAdExampleObservable = Observable<SDKUIFlowActionSettings>.create { observer in
            let cancellable = viewModel.outputs.openPreconversationWithAdExample
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            observer.onError(error)
                        }
                    },
                    receiveValue: { settings in
                        observer.onNext(settings)
                    }
                )

            return Disposables.create {
                cancellable.cancel()
            }
        }

        openPreconversationWithAdExampleObservable
            .subscribe(
                onNext: { [weak self] dataModel in
                    guard let self else { return }
                    let coordinatorData = CoordinatorData.actionsFlowSettings(data: dataModel)
                    guard case CoordinatorData.actionsFlowSettings(let settings) = coordinatorData else {
                        fatalError("MonetizationFlowsCoordinator requires coordinatorData from `CoordinatorData.actionsFlowSettings` type")
                    }

                    let preconversationFlowsWithAdVM: PreconversationFlowsWithAdViewModeling = PreconversationFlowsWithAdViewModel(
                        actionSettings: settings,
                        postId: dataModel.postId
                    )
                    let preconversationFlowsWithAdVC = PreconversationFlowsWithAdVC(viewModel: preconversationFlowsWithAdVM)
                    self.router.push(preconversationFlowsWithAdVC,
                                     animated: true,
                                     completion: nil)
                }
            )
            .disposed(by: disposeBag)
    }
}

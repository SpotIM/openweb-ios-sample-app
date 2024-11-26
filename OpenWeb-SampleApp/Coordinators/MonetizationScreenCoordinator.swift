//
//  MonetizationScreenCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 25/11/2024.
//

import RxSwift

class MonetizationScreenCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {
        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("MonetizationScreenCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let monetizationViewModel: MonetizationViewViewModeling = MonetizationViewViewModel(postId: postId)
        let monetizationVC = MonetizationViewVC(viewModel: monetizationViewModel)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: monetizationViewModel)

        router.push(monetizationVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

private extension MonetizationScreenCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MonetizationViewViewModeling) {
        viewModel.outputs.openIndependentMonetizationExample
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                let independentMonetizationExampleViewModel = IndependentMonetizationExampleViewModel(postId: postId)
                let independentMonetizationExampleVC = IndependentMonetizationExampleVC(viewModel: independentMonetizationExampleViewModel)
                self.router.push(independentMonetizationExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.openSocialMonetizationExample
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                let socialMonetizationExampleViewModel = SocialMonetizationExampleViewModel()
                let socialMonetizationExampleVC = SocialMonetizationExampleVC(viewModel: socialMonetizationExampleViewModel)
                self.router.push(socialMonetizationExampleVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.openPreConversationExample
            .subscribe(onNext: { [weak self] postId in
                guard let self else { return }
                // TODO: PUSH PreConversationExample VIEW
            })
            .disposed(by: disposeBag)
    }
}

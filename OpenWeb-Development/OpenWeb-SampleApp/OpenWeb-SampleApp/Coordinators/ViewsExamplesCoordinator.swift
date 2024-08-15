//
//  ViewsExamplesCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 12/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class ViewsExamplesCoordinator: BaseCoordinator<Void> {

    fileprivate let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.postId(let postId) = data else {
            fatalError("ViewsExamplesCoordinator requires coordinatorData from `CoordinatorData.postId` type")
        }

        let examplesViewModel: UIViewsExamplesViewModeling = UIViewsExamplesViewModel(postId: postId)
        let examplesVC = UIViewsExamplesVC(viewModel: examplesViewModel)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: examplesViewModel)

        router.push(examplesVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

fileprivate extension ViewsExamplesCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: UIViewsExamplesViewModeling) {
        viewModel.outputs.openConversationBelowVideo
            .subscribe(onNext: { [weak self] postId in
                guard let self = self else { return }
                let conversationBelowVideoVM = ConversationBelowVideoViewModel(postId: postId)
                let conversationBelowVideoVC = ConversationBelowVideoVC(viewModel: conversationBelowVideoVM)
                self.router.push(conversationBelowVideoVC,
                                 animated: true,
                                 completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

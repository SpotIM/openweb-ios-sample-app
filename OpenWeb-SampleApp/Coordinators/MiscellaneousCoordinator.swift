//
//  MiscellaneousCoordinator.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 11/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

class MiscellaneousCoordinator: BaseCoordinator<Void> {

    private let router: Routering

    init(router: Routering) {
        self.router = router
    }

    override func start(deepLinkOptions: DeepLinkOptions? = nil,
                        coordinatorData: CoordinatorData? = nil) -> Observable<Void> {

        guard let data = coordinatorData,
              case CoordinatorData.conversationDataModel(let conversationDataModel) = data else {
            fatalError("MiscellaneousCoordinator requires coordinatorData from `CoordinatorData.conversationDataModel` type")
        }

        let miscellaneousVM: MiscellaneousViewModeling = MiscellaneousViewModel(dataModel: conversationDataModel)
        let miscellaneousVC = MiscellaneousVC(viewModel: miscellaneousVM)

        let vcPopped = PublishSubject<Void>()

        setupCoordinatorInternalNavigation(viewModel: miscellaneousVM)

        router.push(miscellaneousVC,
                    animated: true,
                    completion: vcPopped)

        return vcPopped
            .asObservable()
    }
}

private extension MiscellaneousCoordinator {
    func setupCoordinatorInternalNavigation(viewModel: MiscellaneousViewModeling) {
        viewModel.outputs.openConversationCounters
            .asObservable()
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                let conversationCounterVM = ConversationCountersNewAPIViewModel()
                let conversationCounterVC = ConversationCountersNewAPIVC(viewModel: conversationCounterVM)
                self.router.push(conversationCounterVC,
                            animated: true,
                            completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

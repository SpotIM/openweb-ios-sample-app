//
//  TestingPlaygroundIndependentViewViewModel.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 20/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import OpenWebSDK

#if BETA

protocol TestingPlaygroundIndependentViewModelingInputs {

}

protocol TestingPlaygroundIndependentViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var testingPlaygroundView: Observable<UIView> { get }
}

protocol TestingPlaygroundIndependentViewModeling {
    var inputs: TestingPlaygroundIndependentViewModelingInputs { get }
    var outputs: TestingPlaygroundIndependentViewModelingOutputs { get }
}

class TestingPlaygroundIndependentViewModel: TestingPlaygroundIndependentViewModeling,
                                TestingPlaygroundIndependentViewModelingOutputs,
                                TestingPlaygroundIndependentViewModelingInputs {
    var inputs: TestingPlaygroundIndependentViewModelingInputs { return self }
    var outputs: TestingPlaygroundIndependentViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    private let disposeBag = DisposeBag()

    private let _testingPlaygroundView = BehaviorSubject<UIView?>(value: nil)
    var testingPlaygroundView: Observable<UIView> {
        return _testingPlaygroundView
            .unwrap()
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("TestingPlayground", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: NSLocalizedString("TestingPlaygroundLogger", comment: ""))
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension TestingPlaygroundIndependentViewModel {
    func setupObservers() {

        // Testing playground - Views
        Observable.just(())
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                let postId = self.dataModel.postId

                let manager = OpenWeb.manager
                let views = manager.ui.views

                let actionsCallbacks: OWViewActionsCallbacks = { [weak self] callbackType, sourceType, postId in
                    guard let self else { return }
                    let log = "Received OWViewActionsCallback type: \(callbackType), from source: \(sourceType), postId: \(postId)\n"
                    self.loggerViewModel.inputs.log(text: log)
                }

                views.testingPlayground(postId: postId,
                                    additionalSettings: OWTestingPlaygroundSettings(),
                                    callbacks: actionsCallbacks,
                                    completion: { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let view):
                        self._testingPlaygroundView.onNext(view)
                    case .failure(let error):
                        let message = error.description
                        DLog("Calling flows.testingPlayground error: \(message)")
                        self.loggerViewModel.inputs.log(text: message)
                    }
                })
            })
            .disposed(by: disposeBag)
    }
}

#endif

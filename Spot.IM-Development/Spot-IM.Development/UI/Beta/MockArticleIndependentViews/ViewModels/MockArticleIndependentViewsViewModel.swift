//
//  MockArticleIndependentViewsViewModel.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol MockArticleIndependentViewsViewModelingInputs {
}

protocol MockArticleIndependentViewsViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
}

protocol MockArticleIndependentViewsViewModeling {
    var inputs: MockArticleIndependentViewsViewModelingInputs { get }
    var outputs: MockArticleIndependentViewsViewModelingOutputs { get }
}

class MockArticleIndependentViewsViewModel: MockArticleIndependentViewsViewModeling, MockArticleIndependentViewsViewModelingInputs, MockArticleIndependentViewsViewModelingOutputs {
    var inputs: MockArticleIndependentViewsViewModelingInputs { return self }
    var outputs: MockArticleIndependentViewsViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    fileprivate let _actionSettings = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    fileprivate var actionSettings: Observable<SDKUIIndependentViewsActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }

    fileprivate let loggerViewTitle: String

    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()

    lazy var loggerViewModel: UILoggerViewModeling = {
        return UILoggerViewModel(title: loggerViewTitle)
    }()

    init(actionSettings: SDKUIIndependentViewsActionSettings) {
        _actionSettings.onNext(actionSettings)

        switch actionSettings.actionType {
        case .preConversation:
            loggerViewTitle = "Pre conversation logger"
        case .fullConversation:
            loggerViewTitle = "Full conversation logger"
        case .commentCreation:
            loggerViewTitle = "Comment creation logger"
        case .commentThread:
            loggerViewTitle = "Comment thread logger"
        case .independentAdUnit:
            loggerViewTitle = "Independed ad unit logger"
        }

        testLogger()
    }

    func testLogger() {
        let randomInt = Int.random(in: 1000..<9999)
        loggerViewModel.inputs.log(text: "Testing logger with a new event \(randomInt)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.testLogger()
        }
    }
}

#endif

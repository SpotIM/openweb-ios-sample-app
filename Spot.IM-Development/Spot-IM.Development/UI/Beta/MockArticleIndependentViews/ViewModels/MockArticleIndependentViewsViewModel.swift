//
//  MockArticleIndependentViewsViewModel.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import SpotImCore

#if NEW_API

typealias ComponentAndType = (UIView, SDKUIIndependentViewType)

protocol MockArticleIndependentViewsViewModelingInputs {
}

protocol MockArticleIndependentViewsViewModelingOutputs {
    var title: String { get }
    var loggerViewModel: UILoggerViewModeling { get }
    var showComponent: Observable<ComponentAndType> { get }
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

    lazy var showComponent: Observable<ComponentAndType> = {
        return Observable.merge(preConversationUpdater, conversationUpdater, commentCreationUpdater, commentThreadUpdater, independentAdUnitUpdater)
            .flatMapLatest { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self = self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .flatMap { [weak self] viewType -> Observable<ComponentAndType> in
                guard let self = self else { return .empty() }
                return self.retrieveComponent(for: viewType)
                    .map { ($0, viewType) }
            }
    }()

    // All the stuff which should trigger new pre conversation component
    fileprivate lazy var preConversationStyleChanged: Observable<Void> = {
        return self.userDefaultsProvider.values(key: .preConversationCustomStyle, defaultValue: Data())
            .asObservable()
            .flatMap { [weak self] _ -> Observable<SDKUIIndependentViewType> in
                guard let self = self else { return .empty() }
                return self.actionSettings
                    .take(1)
                    .map { $0.viewType }
            }
            .filter { $0 == .preConversation }
            .voidify()
    }()
    fileprivate lazy var preConversationUpdater: Observable<Void> = {
        return Observable.merge(self.preConversationStyleChanged)
    }()

    // All the stuff which should trigger new conversation component
    fileprivate lazy var conversationStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var conversationUpdater: Observable<Void> = {
        return Observable.merge(self.conversationStyleChanged)
    }()

    // All the stuff which should trigger new comment creation component
    fileprivate lazy var commentCreationStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var commentCreationUpdater: Observable<Void> = {
        return Observable.merge(self.commentCreationStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    fileprivate lazy var commentThreadStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var commentThreadUpdater: Observable<Void> = {
        return Observable.merge(self.commentThreadStyleChanged)
    }()

    // All the stuff which should trigger new comment thread component
    fileprivate lazy var independentAdUnitStyleChanged: Observable<Void> = {
        // TODO: Complete once developed
        return Observable.never()
    }()
    fileprivate lazy var independentAdUnitUpdater: Observable<Void> = {
        return Observable.merge(self.independentAdUnitStyleChanged)
    }()

    fileprivate var userDefaultsProvider: UserDefaultsProviderProtocol

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared,
         actionSettings: SDKUIIndependentViewsActionSettings) {
        self.userDefaultsProvider = userDefaultsProvider
        _actionSettings.onNext(actionSettings)

        switch actionSettings.viewType {
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
}

fileprivate extension MockArticleIndependentViewsViewModel {
    func testLogger() {
        let randomInt = Int.random(in: 1000..<9999)
        loggerViewModel.inputs.log(text: "Testing logger with a new event \(randomInt)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.testLogger()
        }
    }

    func retrieveComponent(for viewType: SDKUIIndependentViewType) -> Observable<UIView> {
        switch viewType {
        case .preConversation:
            return self.retrievePreConversation()
        default:
            return Observable.error(GeneralErrors.missingImplementation)
        }
    }

    func retrievePreConversation() -> Observable<UIView> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }

            let preConversationStyleData = self.userDefaultsProvider.get(key: .preConversationCustomStyle, defaultValue: Data())
            let preConversationStyle = OWPreConversationStyle.preConversationStyle(fromData: preConversationStyleData)

            // TODO: Complete once API is ready
            observer.onNext(UIView())
            observer.onCompleted()

            return Disposables.create()
        }
    }
}

#endif

//
//  UIViewsViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 07/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

protocol UIViewsViewModelingInputs {
    var preConversationTapped: PublishSubject<Void> { get }
    var fullConversationTapped: PublishSubject<Void> { get }
    var commentCreationTapped: PublishSubject<Void> { get }
    var commentThreadTapped: PublishSubject<Void> { get }
    var clarityDetailsTapped: PublishSubject<Void> { get }
    var independentAdUnitTapped: PublishSubject<Void> { get }
}

protocol UIViewsViewModelingOutputs {
    var title: String { get }
    var openMockArticleScreen: Observable<SDKUIIndependentViewsActionSettings> { get }
}

protocol UIViewsViewModeling {
    var inputs: UIViewsViewModelingInputs { get }
    var outputs: UIViewsViewModelingOutputs { get }
}

class UIViewsViewModel: UIViewsViewModeling, UIViewsViewModelingOutputs, UIViewsViewModelingInputs {
    var inputs: UIViewsViewModelingInputs { return self }
    var outputs: UIViewsViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    let preConversationTapped = PublishSubject<Void>()
    let fullConversationTapped = PublishSubject<Void>()
    let commentCreationTapped = PublishSubject<Void>()
    let commentThreadTapped = PublishSubject<Void>()
    let clarityDetailsTapped = PublishSubject<Void>()
    let independentAdUnitTapped = PublishSubject<Void>()

    fileprivate let _openMockArticleScreen = BehaviorSubject<SDKUIIndependentViewsActionSettings?>(value: nil)
    var openMockArticleScreen: Observable<SDKUIIndependentViewsActionSettings> {
        return _openMockArticleScreen
            .unwrap()
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("UIViews", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

fileprivate extension UIViewsViewModel {
    func setupObservers() {
        let postId = dataModel.postId

        let fullConversationTappedModel = fullConversationTapped
            .map {
                let viewType = SDKUIIndependentViewType.conversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let commentCreationTappedModel = commentCreationTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.commentCreation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let commentThreadTappedModel = commentThreadTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.commentThread
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let clarityDetailsTappedModel = clarityDetailsTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.clarityDetails
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let preConversationTappedModel = preConversationTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.preConversation
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        let independentAdUnitTappedModel = independentAdUnitTapped
            .map { _ -> SDKUIIndependentViewsActionSettings in
                let viewType = SDKUIIndependentViewType.independentAdUnit
                let model = SDKUIIndependentViewsActionSettings(postId: postId, viewType: viewType)
                return model
            }

        Observable.merge(
            fullConversationTappedModel,
            commentCreationTappedModel,
            commentThreadTappedModel,
            clarityDetailsTappedModel,
            preConversationTappedModel,
            independentAdUnitTappedModel)
        .map { return $0 }
        .bind(to: _openMockArticleScreen)
        .disposed(by: disposeBag)
    }
}

#endif


//
//  OWCommentThreadViewVM.swift
//  SpotImCore
//
//  Created by Alon Shprung on 30/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentThreadViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
}

protocol OWCommentThreadViewViewModelingOutputs {

}

protocol OWCommentThreadViewViewModeling {
    var inputs: OWCommentThreadViewViewModelingInputs { get }
    var outputs: OWCommentThreadViewViewModelingOutputs { get }
}

class OWCommentThreadViewViewModel: OWCommentThreadViewViewModeling, OWCommentThreadViewViewModelingInputs, OWCommentThreadViewViewModelingOutputs {
    var inputs: OWCommentThreadViewViewModelingInputs { return self }
    var outputs: OWCommentThreadViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let _commentThreadData = BehaviorSubject<OWCommentThreadRequiredData?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

    var viewInitialized = PublishSubject<Void>()

    init (commentThreadData: OWCommentThreadRequiredData, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self._commentThreadData.onNext(commentThreadData)
        setupObservers()
    }
}

fileprivate extension OWCommentThreadViewViewModel {
    func setupObservers() {
        // Observable for the conversation network API
        let conversationThreadReadObservable = _commentThreadData.unwrap().flatMap { [weak self] data -> Observable<SPConversationReadRM> in
            guard let self = self else { return .empty() }
            return self.servicesProvider
            .netwokAPI()
            .conversation
            .conversationRead(mode: .newest, page: OWPaginationPage.first, messageId: data.commentId)
            .response
        }

        let commentThreadFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<SPConversationReadRM> in
                return conversationThreadReadObservable
                    .take(1)
            }
            .share()

        commentThreadFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self, let responseComments = response.conversation?.comments else { return }
                // TODO - Build cells from response
                print(responseComments)
            })
            .disposed(by: disposeBag)
    }
}

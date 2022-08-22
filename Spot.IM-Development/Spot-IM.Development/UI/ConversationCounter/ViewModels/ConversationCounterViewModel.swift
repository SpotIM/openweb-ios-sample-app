//
//  ConversationCounterViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 22/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import Alamofire
import SpotImCore

protocol ConversationCounterViewModelingInputs {
    var loadConversationCounter: PublishSubject<String> { get }
}

protocol ConversationCounterViewModelingOutputs {
    var title: String { get }
    var comments: Observable<Int> { get }
    var replies: Observable<Int> { get }
    var showError: Observable<String> { get }
}

protocol ConversationCounterViewModeling {
    var inputs: ConversationCounterViewModelingInputs { get }
    var outputs: ConversationCounterViewModelingOutputs { get }
}

class ConversationCounterViewModel: ConversationCounterViewModeling, ConversationCounterViewModelingInputs, ConversationCounterViewModelingOutputs {
    var inputs: ConversationCounterViewModelingInputs { return self }
    var outputs: ConversationCounterViewModelingOutputs { return self }
    
    lazy var title: String = {
        return NSLocalizedString("ConversationCounterTitle", comment: "")
    }()
    
    let loadConversationCounter = PublishSubject<String>()
    
    fileprivate let _comments = BehaviorSubject<Int?>(value: nil)
    var comments: Observable<Int> {
        return _comments
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _replies = BehaviorSubject<Int?>(value: nil)
    var replies: Observable<Int> {
        return _replies
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _showError = BehaviorSubject<String?>(value: nil)
    var showError: Observable<String> {
        return _showError
            .unwrap()
            .asObservable()
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    init() {
        setupObservers()
    }
}

fileprivate extension ConversationCounterViewModel {
    func setupObservers() {
        loadConversationCounter
            .subscribe(onNext: { [weak self] postId in
                guard let self = self else { return }
                SpotIm.getConversationCounters(conversationIds: [postId]) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(let commentDic):
                        guard let counter = commentDic[postId] else {
                            let err = "Failed to parse the conversation counter for the given postId"
                            DLog(err)
                            self._showError.onNext(err)
                            return
                        }
                        let comments = counter.comments
                        let replies = counter.replies
                        self._comments.onNext(comments)
                        self._replies.onNext(replies)
                    case .failure(let error):
                        DLog(error)
                        self._showError.onNext(error.localizedDescription)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

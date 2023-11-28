//
//  ConversationCountersNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import SpotImCore

protocol ConversationCountersNewAPIViewModelingInputs {
    var userPostIdsInput: BehaviorSubject<String> { get }
    var loadConversationCounter: PublishSubject<Void> { get }
}

protocol ConversationCountersNewAPIViewModelingOutputs {
    var title: String { get }
    var showLoader: Observable<Bool> { get }
    var showError: Observable<String> { get }
    var cellsViewModels: Observable<[ConversationCounterNewAPICellViewModeling]> { get }
}

protocol ConversationCountersNewAPIViewModeling {
    var inputs: ConversationCountersNewAPIViewModelingInputs { get }
    var outputs: ConversationCountersNewAPIViewModelingOutputs { get }
}

class ConversationCountersNewAPIViewModel: ConversationCountersNewAPIViewModeling,
                                           ConversationCountersNewAPIViewModelingInputs,
                                           ConversationCountersNewAPIViewModelingOutputs {
    var inputs: ConversationCountersNewAPIViewModelingInputs { return self }
    var outputs: ConversationCountersNewAPIViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let parsingSeparator: String = ", "
    }

    lazy var title: String = {
        return NSLocalizedString("ConversationCounterTitle", comment: "")
    }()
    let userPostIdsInput = BehaviorSubject<String>(value: "")
    let loadConversationCounter = PublishSubject<Void>()

    fileprivate let _showLoader = BehaviorSubject<Bool?>(value: nil)
    var showLoader: Observable<Bool> {
        return _showLoader
            .unwrap()
            .asObservable()
    }

    fileprivate let _showError = BehaviorSubject<String?>(value: nil)
    var showError: Observable<String> {
        return _showError
            .unwrap()
            .asObservable()
    }

    fileprivate let _cellsViewModels = BehaviorSubject<[ConversationCounterNewAPICellViewModeling]?>(value: nil)
    var cellsViewModels: Observable<[ConversationCounterNewAPICellViewModeling]> {
        _cellsViewModels
            .unwrap()
            .asObservable()
            .startWith([])
    }

    fileprivate let disposeBag = DisposeBag()

    init() {
        setupObservers()
    }
}

fileprivate extension ConversationCountersNewAPIViewModel {
    func setupObservers() {
        loadConversationCounter
            .do(onNext: { [weak self] _ in
                self?._showLoader.onNext(true)
                self?._showError.onNext(nil)
                self?._cellsViewModels.onNext([])
            })
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self = self else { return Observable.empty() }
                return self.userPostIdsInput
                    .take(1)
            }
            .map { [weak self] userInput -> [String] in
                guard let self = self else { return [] }
                return self.parse(postIds: userInput)
            }
            .subscribe(onNext: { [weak self] postIds in
                guard let self = self else { return }
                let helper = OpenWeb.manager.helpers
                helper.conversationCounters(forPostIds: postIds) { [weak self] result in
                    guard let self = self else { return }
                    self._showLoader.onNext(false)

                    switch result {
                    case .success(let commentDict):
                        let postIdsKeys = commentDict.keys
                        var cellViewModels = [ConversationCounterNewAPICellViewModeling]()

                        for id in postIdsKeys {
                            guard let counter = commentDict[id] else { continue }
                            let cellViewModel = ConversationCounterNewAPICellViewModel(counter: counter, postId: id)
                            cellViewModels.append(cellViewModel)
                        }

                        self._cellsViewModels.onNext(cellViewModels)
                    case .failure(let error):
                        DLog(error)
                        self._showError.onNext(error.description)
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func parse(postIds: String) -> [String] {
        guard !postIds.isEmpty else { return [] }
        return postIds
            .components(separatedBy: Metrics.parsingSeparator)
            .map { $0.replacingOccurrences(of: " ", with: "") } // Remove extra possible white spaces
    }
}

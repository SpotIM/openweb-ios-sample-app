//
//  ConversationCountersNewAPIViewModel.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import RxSwift
import UIKit
import OpenWebSDK

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

    private struct Metrics {
        static let parsingSeparator: String = ", "
    }

    lazy var title: String = {
        return NSLocalizedString("ConversationCounterTitle", comment: "")
    }()
    let userPostIdsInput = BehaviorSubject<String>(value: "")
    let loadConversationCounter = PublishSubject<Void>()

    private let _showLoader = BehaviorSubject<Bool?>(value: nil)
    var showLoader: Observable<Bool> {
        return _showLoader
            .unwrap()
            .asObservable()
    }

    private let _showError = BehaviorSubject<String?>(value: nil)
    var showError: Observable<String> {
        return _showError
            .unwrap()
            .asObservable()
    }

    private let _cellsViewModels = BehaviorSubject<[ConversationCounterNewAPICellViewModeling]?>(value: nil)
    var cellsViewModels: Observable<[ConversationCounterNewAPICellViewModeling]> {
        _cellsViewModels
            .unwrap()
            .asObservable()
            .startWith([])
    }

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private let disposeBag = DisposeBag()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension ConversationCountersNewAPIViewModel {
    func setupObservers() {
        loadConversationCounter
            .do(onNext: { [weak self] _ in
                self?._showLoader.onNext(true)
                self?._showError.onNext(nil)
                self?._cellsViewModels.onNext([])
            })
            .flatMapLatest { [weak self] _ -> Observable<String> in
                guard let self else { return Observable.empty() }
                return self.userPostIdsInput
                    .take(1)
            }
            .map { [weak self] userInput -> [String] in
                guard let self else { return [] }
                return self.parse(postIds: userInput)
            }
            .subscribe(onNext: { [weak self] postIds in
                guard let self else { return }
                let helper = OpenWeb.manager.helpers
                if shouldUseAsyncAwaitCallingMethod() {
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        do {
                            let counts = try await helper.conversationCounters(forPostIds: postIds)
                            updateCells(counts: counts)
                        } catch {
                            DLog(error)
                            self._showError.onNext(error.localizedDescription)
                        }
                        self._showLoader.onNext(false)
                    }
                } else {
                    helper.conversationCounters(forPostIds: postIds) { [weak self] result in
                        guard let self else { return }
                        self._showLoader.onNext(false)

                        switch result {
                        case .success(let commentDict):
                            updateCells(counts: commentDict)
                        case .failure(let error):
                            DLog(error)
                            self._showError.onNext(error.description)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }

    func updateCells(counts: [OWPostId: OWConversationCounter]) {
        let cellViewModels = counts.map { id, counter in
            ConversationCounterNewAPICellViewModel(counter: counter, postId: id)
        }

        _cellsViewModels.onNext(cellViewModels)
    }

    func parse(postIds: String) -> [String] {
        guard !postIds.isEmpty else { return [] }
        return postIds
            .components(separatedBy: Metrics.parsingSeparator)
            .map { $0.replacingOccurrences(of: " ", with: "") } // Remove extra possible white spaces
    }

    func shouldUseAsyncAwaitCallingMethod() -> Bool {
        return SampleAppCallingMethod.asyncAwait == userDefaultsProvider.get(key: .callingMethodOption, defaultValue: .default)
    }
}

//
//  ConversationCountersNewAPIViewModel.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import UIKit
import OpenWebSDK
import Combine
import CombineExt

protocol ConversationCountersNewAPIViewModelingInputs {
    var userPostIdsInput: CurrentValueSubject<String, Never> { get }
    var loadConversationCounter: PassthroughSubject<Void, Never> { get }
}

protocol ConversationCountersNewAPIViewModelingOutputs {
    var title: String { get }
    var showLoader: AnyPublisher<Bool, Never> { get }
    var showError: AnyPublisher<String, Never> { get }
    var cellsViewModels: AnyPublisher<[ConversationCounterNewAPICellViewModel], Never> { get }
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
    let userPostIdsInput = CurrentValueSubject<String, Never>("")
    let loadConversationCounter = PassthroughSubject<Void, Never>()

    private let _showLoader = CurrentValueSubject<Bool?, Never>(nil)
    var showLoader: AnyPublisher<Bool, Never> {
        return _showLoader
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _showError = CurrentValueSubject<String?, Never>(nil)
    var showError: AnyPublisher<String, Never> {
        return _showError
            .unwrap()
            .eraseToAnyPublisher()
    }

    private let _cellsViewModels = CurrentValueSubject<[ConversationCounterNewAPICellViewModel]?, Never>(nil)
    var cellsViewModels: AnyPublisher<[ConversationCounterNewAPICellViewModel], Never> {
        _cellsViewModels
            .unwrap()
            .prepend([])
            .eraseToAnyPublisher()
    }

    private let userDefaultsProvider: UserDefaultsProviderProtocol
    private var cancellables = Set<AnyCancellable>()

    init(userDefaultsProvider: UserDefaultsProviderProtocol = UserDefaultsProvider.shared) {
        self.userDefaultsProvider = userDefaultsProvider
        setupObservers()
    }
}

private extension ConversationCountersNewAPIViewModel {
    func setupObservers() {
        loadConversationCounter
            .handleEvents(receiveOutput: { [weak self] _ in
                self?._showLoader.send(true)
                self?._showError.send(nil)
                self?._cellsViewModels.send([])
            })
            .flatMapLatest { [weak self] _ -> AnyPublisher<String, Never> in
                guard let self else { return Empty<String, Never>().eraseToAnyPublisher() }
                return self.userPostIdsInput
                    .prefix(1)
                    .eraseToAnyPublisher()
            }
            .map { [weak self] userInput -> [String] in
                guard let self else { return [] }
                return self.parse(postIds: userInput)
            }
            .sink { [weak self] postIds in
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
                            self._showError.send(error.localizedDescription)
                        }
                        self._showLoader.send(false)
                    }
                } else {
                    helper.conversationCounters(forPostIds: postIds) { [weak self] result in
                        guard let self else { return }
                        self._showLoader.send(false)

                        switch result {
                        case .success(let commentDict):
                            updateCells(counts: commentDict)
                        case .failure(let error):
                            DLog(error)
                            self._showError.send(error.description)
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }

    func updateCells(counts: [OWPostId: OWConversationCounter]) {
        let cellViewModels = counts.map { id, counter in
            ConversationCounterNewAPICellViewModel(counter: counter, postId: id)
        }

        _cellsViewModels.send(cellViewModels)
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

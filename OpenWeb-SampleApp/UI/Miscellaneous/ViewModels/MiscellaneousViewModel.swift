//
//  MiscellaneousViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 05/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import Combine

protocol MiscellaneousViewModelingInputs {
    var conversationCounterTapped: PassthroughSubject<Void, Never> { get }
}

protocol MiscellaneousViewModelingOutputs {
    var title: String { get }
    var openConversationCounters: AnyPublisher<Void, Never> { get }
}

protocol MiscellaneousViewModeling {
    var inputs: MiscellaneousViewModelingInputs { get }
    var outputs: MiscellaneousViewModelingOutputs { get }
}

class MiscellaneousViewModel: MiscellaneousViewModeling,
                                MiscellaneousViewModelingOutputs,
                                MiscellaneousViewModelingInputs {
    var inputs: MiscellaneousViewModelingInputs { return self }
    var outputs: MiscellaneousViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    let conversationCounterTapped = PassthroughSubject<Void, Never>()
    var openConversationCounters: AnyPublisher<Void, Never> {
        return conversationCounterTapped
            .eraseToAnyPublisher()
    }

    lazy var title: String = {
        return NSLocalizedString("Miscellaneous", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension MiscellaneousViewModel {

    func setupObservers() { }
}

//
//  ConversationCountersNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import SpotImCore

#if NEW_API
protocol ConversationCountersNewAPIViewModelingInputs {
    var userPostIdsInput: BehaviorSubject<String> { get }
    var loadConversationCounter: PublishSubject<Void> { get }
}

protocol ConversationCountersNewAPIViewModelingOutputs {
    var title: String { get }
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

    lazy var title: String = {
        return NSLocalizedString("ConversationCounterTitle", comment: "")
    }()
    let userPostIdsInput = BehaviorSubject<String>(value: "")
    let loadConversationCounter = PublishSubject<Void>()
}

#endif

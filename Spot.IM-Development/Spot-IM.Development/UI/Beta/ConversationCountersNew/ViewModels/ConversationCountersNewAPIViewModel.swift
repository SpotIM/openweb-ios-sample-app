//
//  ConversationCountersNewAPIViewModel.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
protocol ConversationCountersNewAPIViewModelingInputs {
}

protocol ConversationCountersNewAPIViewModelingOutputs {
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
    
}

#endif

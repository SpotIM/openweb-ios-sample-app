//
//  OWConversationEmptyStateCellViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 14/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Should be changed to cell to support Views and small devices
protocol OWConversationEmptyStateCellViewModelingInputs {

}

protocol OWConversationEmptyStateCellViewModelingOutputs {
    var id: String { get }
    var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling { get }
}

protocol OWConversationEmptyStateCellViewModeling: OWCellViewModel {
    var inputs: OWConversationEmptyStateCellViewModelingInputs { get }
    var outputs: OWConversationEmptyStateCellViewModelingOutputs { get }
}

class OWConversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling,
                                             OWConversationEmptyStateCellViewModelingInputs,
                                             OWConversationEmptyStateCellViewModelingOutputs {
    var inputs: OWConversationEmptyStateCellViewModelingInputs { return self }
    var outputs: OWConversationEmptyStateCellViewModelingOutputs { return self }

    lazy var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling = {
        return OWConversationEmptyStateViewModel()
    }()

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWConversationEmptyStateCellViewModel {
    static func stub() -> OWConversationEmptyStateCellViewModeling {
        return OWConversationEmptyStateCellViewModel()
    }
}

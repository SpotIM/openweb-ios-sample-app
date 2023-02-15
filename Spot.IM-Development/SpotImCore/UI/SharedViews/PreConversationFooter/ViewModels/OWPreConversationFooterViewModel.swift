//
//  OWPreConversationFooterViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// TODO: complete
protocol OWPreConversationFooterViewModelingInputs {

}

protocol OWPreConversationFooterViewModelingOutputs {

}

protocol OWPreConversationFooterViewModeling {
    var inputs: OWPreConversationFooterViewModelingInputs { get }
    var outputs: OWPreConversationFooterViewModelingOutputs { get }
}

class OWPreConversationFooterViewModel: OWPreConversationFooterViewModeling, OWPreConversationFooterViewModelingInputs, OWPreConversationFooterViewModelingOutputs {
    var inputs: OWPreConversationFooterViewModelingInputs { return self }
    var outputs: OWPreConversationFooterViewModelingOutputs { return self }
}

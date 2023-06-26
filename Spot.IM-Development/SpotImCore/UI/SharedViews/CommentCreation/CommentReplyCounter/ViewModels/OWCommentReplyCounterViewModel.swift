//
//  OWCommentReplyCounterViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 26/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentReplyCounterViewModelingInputs {

}

protocol OWCommentReplyCounterViewModelingOutputs {

}

protocol OWCommentReplyCounterViewModeling {
    var inputs: OWCommentReplyCounterViewModelingInputs { get }
    var outputs: OWCommentReplyCounterViewModelingOutputs { get }
}

class OWCommentReplyCounterViewModel: OWCommentReplyCounterViewModeling,
                                        OWCommentReplyCounterViewModelingInputs,
                                        OWCommentReplyCounterViewModelingOutputs {

    var inputs: OWCommentReplyCounterViewModelingInputs { return self }
    var outputs: OWCommentReplyCounterViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

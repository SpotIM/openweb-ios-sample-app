//
//  OWCommentActionsViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 06/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentActionsViewModelingInputs {
    func configureRankUp(_ count: Int)
    func configureRankDown(_ count: Int)
    func configureRankedByUser(_ value: Int)
}

protocol OWCommentActionsViewModelingOutputs {
    var votingVM: OWCommentVotingViewModeling { get }
}

protocol OWCommentActionsViewModeling {
    var inputs: OWCommentActionsViewModelingInputs { get }
    var outputs: OWCommentActionsViewModelingOutputs { get }
}

class OWCommentActionsViewModel: OWCommentActionsViewModeling,
                                 OWCommentActionsViewModelingInputs,
                                 OWCommentActionsViewModelingOutputs {

    var inputs: OWCommentActionsViewModelingInputs { return self }
    var outputs: OWCommentActionsViewModelingOutputs { return self }
    
    let votingVM: OWCommentVotingViewModeling = OWCommentVotingViewModel()
    
    func configureRankUp(_ count: Int) {
        self.votingVM.inputs.configureRankUp(count)
    }
    
    func configureRankDown(_ count: Int) {
        self.votingVM.inputs.configureRankDown(count)
    }
    
    func configureRankedByUser(_ value: Int) {
        self.votingVM.inputs.configureRankedByUser(value)
    }
}

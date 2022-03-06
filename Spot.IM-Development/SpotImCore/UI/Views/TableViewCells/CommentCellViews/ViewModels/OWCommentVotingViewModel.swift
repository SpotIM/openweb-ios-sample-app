//
//  OWCommentVotingViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 06/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentVotingViewModelingInputs {

}

protocol OWCommentVotingViewModelingOutputs {

}

protocol OWCommentVotingViewModeling {
    var inputs: OWCommentVotingViewModelingInputs { get }
    var outputs: OWCommentVotingViewModelingOutputs { get }
}

class OWCommentVotingViewModel: OWCommentVotingViewModeling,
                                OWCommentVotingViewModelingInputs,
                                OWCommentVotingViewModelingOutputs {

    var inputs: OWCommentVotingViewModelingInputs { return self }
    var outputs: OWCommentVotingViewModelingOutputs { return self }
    
    init () {

    }
}

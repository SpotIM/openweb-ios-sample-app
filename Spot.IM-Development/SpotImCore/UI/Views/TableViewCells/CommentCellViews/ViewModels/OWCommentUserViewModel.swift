//
//  OWCommentUserViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 20/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWCommentUserViewModelingInputs {
    
}

protocol OWCommentUserViewModelingOutputs {
    
}

protocol OWCommentUserViewModeling {
    var inputs: OWCommentUserViewModelingInputs { get }
    var outputs: OWCommentUserViewModelingOutputs { get }
}

class OWCommentUserViewModel: OWCommentUserViewModeling,
                              OWCommentUserViewModelingInputs,
                              OWCommentUserViewModelingOutputs {

    var inputs: OWCommentUserViewModelingInputs { return self }
    var outputs: OWCommentUserViewModelingOutputs { return self }
}

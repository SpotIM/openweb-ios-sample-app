//
//  OWTestingRedFirstLevelViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

#if BETA

import Foundation
import RxSwift

protocol OWTestingRedFirstLevelViewModelingInputs { }

protocol OWTestingRedFirstLevelViewModelingOutputs {
    var secondLevelVM: OWTestingRedSecondLevelViewModeling { get }
}

protocol OWTestingRedFirstLevelViewModeling {
    var inputs: OWTestingRedFirstLevelViewModelingInputs { get }
    var outputs: OWTestingRedFirstLevelViewModelingOutputs { get }
}

class OWTestingRedFirstLevelViewModel: OWTestingRedFirstLevelViewModeling,
                                OWTestingRedFirstLevelViewModelingInputs,
                                OWTestingRedFirstLevelViewModelingOutputs {
    var inputs: OWTestingRedFirstLevelViewModelingInputs { return self }
    var outputs: OWTestingRedFirstLevelViewModelingOutputs { return self }

    fileprivate let id: String

    init(id: String) {
        self.id = id
    }

    lazy var secondLevelVM: OWTestingRedSecondLevelViewModeling = {
        return OWTestingRedSecondLevelViewModel(id: id)
    }()
}

#endif

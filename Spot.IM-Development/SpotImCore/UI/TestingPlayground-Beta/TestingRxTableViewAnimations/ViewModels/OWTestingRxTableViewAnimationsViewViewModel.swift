//
//  OWTestingRxTableViewAnimationsViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 25/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if BETA

import UIKit
import RxSwift

protocol OWTestingRxTableViewAnimationsViewViewModelingInputs { }

protocol OWTestingRxTableViewAnimationsViewViewModelingOutputs {
    var redCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
    var blueCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
    var greenCellsGeneratorVM: OWTestingCellsGeneratorViewModeling { get }
}

protocol OWTestingRxTableViewAnimationsViewViewModeling {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { get }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { get }
}

class OWTestingRxTableViewAnimationsViewViewModel: OWTestingRxTableViewAnimationsViewViewModeling,
                                OWTestingRxTableViewAnimationsViewViewModelingInputs,
                                OWTestingRxTableViewAnimationsViewViewModelingOutputs {
    var inputs: OWTestingRxTableViewAnimationsViewViewModelingInputs { return self }
    var outputs: OWTestingRxTableViewAnimationsViewViewModelingOutputs { return self }

    lazy var redCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .red, title: "Red")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

    lazy var blueCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .blue, title: "Blue")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

    lazy var greenCellsGeneratorVM: OWTestingCellsGeneratorViewModeling = {
        let requiredData = OWTestingCellsGeneratorRequiredData(color: .green, title: "Green")
        return OWTestingCellsGeneratorViewModel(requiredData: requiredData)
    }()

}

#endif

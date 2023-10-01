//
//  OWClarityDetailsVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 22/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWClarityDetailsViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWClarityDetailsViewModelingOutputs {
    var clarityDetailsViewViewModel: OWClarityDetailsViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
}

protocol OWClarityDetailsViewModeling {
    var inputs: OWClarityDetailsViewModelingInputs { get }
    var outputs: OWClarityDetailsViewModelingOutputs { get }
}

class OWClarityDetailsVM: OWClarityDetailsViewModeling,
                                 OWClarityDetailsViewModelingInputs,
                          OWClarityDetailsViewModelingOutputs {

    var inputs: OWClarityDetailsViewModelingInputs { return self }
    var outputs: OWClarityDetailsViewModelingOutputs { return self }

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    fileprivate let type: OWClarityDetailsType
    lazy var clarityDetailsViewViewModel: OWClarityDetailsViewViewModeling = {
        return OWClarityDetailsViewVM(type: type)
    }()

    init(type: OWClarityDetailsType, viewableMode: OWViewableMode) {
        self.type = type
    }
}


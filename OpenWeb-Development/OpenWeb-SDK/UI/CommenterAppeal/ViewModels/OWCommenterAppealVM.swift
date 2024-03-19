//
//  OWCommenterAppealVM.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommenterAppealViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
}

protocol OWCommenterAppealViewModelingOutputs {
    var commenterAppealViewViewModel: OWCommenterAppealViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
}

protocol OWCommenterAppealViewModeling {
    var inputs: OWCommenterAppealViewModelingInputs { get }
    var outputs: OWCommenterAppealViewModelingOutputs { get }
}

class OWCommenterAppealVM: OWCommenterAppealViewModeling,
                           OWCommenterAppealViewModelingInputs,
                           OWCommenterAppealViewModelingOutputs {

    var inputs: OWCommenterAppealViewModelingInputs { return self }
    var outputs: OWCommenterAppealViewModelingOutputs { return self }

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    lazy var commenterAppealViewViewModel: OWCommenterAppealViewViewModeling = {
        return OWCommenterAppealViewVM(data: data, viewableMode: viewableMode, presentationalMode: presentationalMode)
    }()

    fileprivate let data: OWAppealRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let presentationalMode: OWPresentationalModeCompact
    init(data: OWAppealRequiredData, viewableMode: OWViewableMode, presentationalMode: OWPresentationalModeCompact) {
        self.data = data
        self.viewableMode = viewableMode
        self.presentationalMode = presentationalMode
    }
}


//
//  MicellaneousViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 05/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

#if NEW_API

protocol MiscellaneousViewModelingInputs {
    var conversationCounterTapped: PublishSubject<Void> { get }
}

protocol MiscellaneousViewModelingOutputs {
    var title: String { get }
}

protocol MiscellaneousViewModeling {
    var inputs: MiscellaneousViewModelingInputs { get }
    var outputs: MiscellaneousViewModelingOutputs { get }
}

class MiscellaneousViewModel: MiscellaneousViewModeling, MiscellaneousViewModelingOutputs, MiscellaneousViewModelingInputs {
    var inputs: MiscellaneousViewModelingInputs { return self }
    var outputs: MiscellaneousViewModelingOutputs { return self }

    fileprivate let dataModel: SDKConversationDataModel

    fileprivate let disposeBag = DisposeBag()

    let conversationCounterTapped = PublishSubject<Void>()

    lazy var title: String = {
        return NSLocalizedString("Miscellaneous", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

fileprivate extension MiscellaneousViewModel {

    func setupObservers() { }
}

#endif


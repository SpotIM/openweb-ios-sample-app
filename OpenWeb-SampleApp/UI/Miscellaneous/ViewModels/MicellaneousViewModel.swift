//
//  MicellaneousViewModel.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 05/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol MiscellaneousViewModelingInputs {
    var conversationCounterTapped: PublishSubject<Void> { get }
}

protocol MiscellaneousViewModelingOutputs {
    var title: String { get }
    var openConversationCounters: Observable<Void> { get }
}

protocol MiscellaneousViewModeling {
    var inputs: MiscellaneousViewModelingInputs { get }
    var outputs: MiscellaneousViewModelingOutputs { get }
}

class MiscellaneousViewModel: MiscellaneousViewModeling,
                                MiscellaneousViewModelingOutputs,
                                MiscellaneousViewModelingInputs {
    var inputs: MiscellaneousViewModelingInputs { return self }
    var outputs: MiscellaneousViewModelingOutputs { return self }

    private let dataModel: SDKConversationDataModel

    private let disposeBag = DisposeBag()

    let conversationCounterTapped = PublishSubject<Void>()
    var openConversationCounters: Observable<Void> {
        return conversationCounterTapped
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("Miscellaneous", comment: "")
    }()

    init(dataModel: SDKConversationDataModel) {
        self.dataModel = dataModel
        setupObservers()
    }
}

private extension MiscellaneousViewModel {

    func setupObservers() { }
}

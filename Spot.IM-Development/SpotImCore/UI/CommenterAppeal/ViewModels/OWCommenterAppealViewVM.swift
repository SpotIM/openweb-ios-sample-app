//
//  OWCommenterAppealViewVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 01/11/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommenterAppealViewViewModelingInputs {
    var closeClick: PublishSubject<Void> { get }
}

protocol OWCommenterAppealViewViewModelingOutputs {
    var closeButtonPopped: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
}

protocol OWCommenterAppealViewViewModeling {
    var inputs: OWCommenterAppealViewViewModelingInputs { get }
    var outputs: OWCommenterAppealViewViewModelingOutputs { get }
}

class OWCommenterAppealViewVM: OWCommenterAppealViewViewModeling,
                               OWCommenterAppealViewViewModelingInputs,
                               OWCommenterAppealViewViewModelingOutputs {
    fileprivate struct Metrics {
        static let defaultTextViewMaxCharecters = 280
    }

    var inputs: OWCommenterAppealViewViewModelingInputs { return self }
    var outputs: OWCommenterAppealViewViewModelingOutputs { return self }

    fileprivate var disposeBag: DisposeBag
    fileprivate let servicesProvider: OWSharedServicesProviding

    let textViewVM: OWTextViewViewModeling
    
    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()
        let textViewData = OWTextViewData(textViewMaxCharecters: Metrics.defaultTextViewMaxCharecters,
                                          placeholderText: "You can add additional information here", // TODO: placeholder is changed if its mendatory or not
                                          charectersLimitEnabled: false,
                                          isEditable: false)
        self.textViewVM = OWTextViewViewModel(textViewData: textViewData)
        setupObservers()
    }

    var closeClick = PublishSubject<Void>()
    lazy var closeButtonPopped: Observable<Void> = {
        return closeClick
            .asObservable()
    }()
}

fileprivate extension OWCommenterAppealViewVM {
    func setupObservers() {
    }
}

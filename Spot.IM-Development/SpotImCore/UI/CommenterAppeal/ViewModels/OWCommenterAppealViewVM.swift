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
}

protocol OWCommenterAppealViewViewModeling {
    var inputs: OWCommenterAppealViewViewModelingInputs { get }
    var outputs: OWCommenterAppealViewViewModelingOutputs { get }
}

class OWCommenterAppealViewVM: OWCommenterAppealViewViewModeling,
                               OWCommenterAppealViewViewModelingInputs,
                               OWCommenterAppealViewViewModelingOutputs {
    var inputs: OWCommenterAppealViewViewModelingInputs { return self }
    var outputs: OWCommenterAppealViewViewModelingOutputs { return self }

    fileprivate var disposeBag: DisposeBag
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()

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

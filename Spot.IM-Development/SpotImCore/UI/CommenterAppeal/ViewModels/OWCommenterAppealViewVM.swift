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
    var reasonIndexSelect: BehaviorSubject<Int?> { get }
}

protocol OWCommenterAppealViewViewModelingOutputs {
    var closeButtonPopped: Observable<Void> { get }
    var textViewVM: OWTextViewViewModeling { get }
    var appealCellViewModels: Observable<[OWReportReasonCellViewModeling]> { get }
    var selectedReason: Observable<OWReportReason> { get }
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

    // TODO: where do we get it from?
    lazy var appealOptions: Observable<[OWReportReason]> = {
        self.servicesProvider.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .map { $0.shared?.reportReasonsOptions?.reportReasons }
            .unwrap()
            .asObservable()
            .share(replay: 1)
    }()
    // TODO: dedicated cell vm
    lazy var appealCellViewModels: Observable<[OWReportReasonCellViewModeling]> = {
        appealOptions
            .map { reasons in
                var viewModels: [OWReportReasonCellViewModeling] = []
                for reason in reasons {
                    viewModels.append(OWReportReasonCellViewModel(reason: reason))
                }
                return viewModels
            }
            .asObservable()
    }()

    var reasonIndexSelect = BehaviorSubject<Int?>(value: nil)
    lazy var selectedReason: Observable<OWReportReason> = {
        reasonIndexSelect
            .skip(1)
            .unwrap()
            .flatMap { [weak self] index -> Observable<OWReportReason> in
                guard let self = self else { return .empty() }
                return self.appealOptions
                    .map { $0[index] }
            }
            .share(replay: 1)
    }()
}

fileprivate extension OWCommenterAppealViewVM {
    func setupObservers() {
    }
}

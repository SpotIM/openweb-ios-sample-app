//
//  OWReportReasonVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 17/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWReportReasonViewModelingInputs {
    var viewDidLoad: PublishSubject<Void> { get }
    var changeIsLargeTitleDisplay: PublishSubject<Bool> { get }
}

protocol OWReportReasonViewModelingOutputs {
    var reportReasonViewViewModel: OWReportReasonViewViewModeling { get }
    var loadedToScreen: Observable<Void> { get }
    var title: String { get }
    var viewableMode: OWViewableMode { get }
    var isLargeTitleDisplay: Observable<Bool> { get }
}

protocol OWReportReasonViewModeling {
    var inputs: OWReportReasonViewModelingInputs { get }
    var outputs: OWReportReasonViewModelingOutputs { get }
}

class OWReportReasonViewModel: OWReportReasonViewModeling, OWReportReasonViewModelingInputs, OWReportReasonViewModelingOutputs {
    var inputs: OWReportReasonViewModelingInputs { return self }
    var outputs: OWReportReasonViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    let viewableMode: OWViewableMode
    let presentationalMode: OWPresentationalModeCompact
    fileprivate let servicesProvider: OWSharedServicesProviding

    lazy var reportReasonViewViewModel: OWReportReasonViewViewModeling = {
        return OWReportReasonViewViewModel(reportData: reportData,
                                           viewableMode: viewableMode,
                                           presentationalMode: presentationalMode)
    }()

    lazy var title: String = {
        return OWLocalizationManager.shared.localizedString(key: "ReportReasonTitle")
    }()

    fileprivate let reportData: OWReportReasonsRequiredData

    fileprivate lazy var _isLargeTitleDisplay: BehaviorSubject<Bool> = {
        return BehaviorSubject<Bool>(value: servicesProvider.navigationControllerCustomizer().isLargeTitlesEnabled())
    }()

    var changeIsLargeTitleDisplay = PublishSubject<Bool>()
    var isLargeTitleDisplay: Observable<Bool> {
        return _isLargeTitleDisplay
    }

    init(reportData: OWReportReasonsRequiredData,
         viewableMode: OWViewableMode,
         presentMode: OWPresentationalModeCompact,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.reportData = reportData
        self.viewableMode = viewableMode
        self.presentationalMode = presentMode
        self.servicesProvider = servicesProvider

        setupObservers()
    }
}

fileprivate extension OWReportReasonViewModel {
    func setupObservers() {
        changeIsLargeTitleDisplay
            .bind(to: _isLargeTitleDisplay)
            .disposed(by: disposeBag)
    }
}

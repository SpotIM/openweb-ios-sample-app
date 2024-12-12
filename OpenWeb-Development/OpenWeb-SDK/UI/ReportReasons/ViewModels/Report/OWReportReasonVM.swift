//
//  OWReportReasonVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 17/04/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
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

    private let disposeBag = DisposeBag()

    var viewDidLoad = PublishSubject<Void>()
    var loadedToScreen: Observable<Void> {
        return viewDidLoad.asObservable()
    }

    let viewableMode: OWViewableMode
    let presentationalMode: OWPresentationalModeCompact
    private let servicesProvider: OWSharedServicesProviding

    lazy var reportReasonViewViewModel: OWReportReasonViewViewModeling = {
        return OWReportReasonViewViewModel(reportData: reportData,
                                           viewableMode: viewableMode,
                                           presentationalMode: presentationalMode)
    }()

    lazy var title: String = {
        return OWLocalize.string("ReportReasonTitle")
    }()

    private let reportData: OWReportReasonsRequiredData

    private lazy var _isLargeTitleDisplay: BehaviorSubject<Bool> = {
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

private extension OWReportReasonViewModel {
    func setupObservers() {
        changeIsLargeTitleDisplay
            .bind(to: _isLargeTitleDisplay)
            .disposed(by: disposeBag)
    }
}

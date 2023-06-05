//
//  OWOnlineViewingUsersCounterViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 27/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

protocol OWOnlineViewingUsersCounterViewModelingInputs {
    var triggerCustomizeIconImageViewUI: PublishSubject<UIImageView> { get }
    var triggerCustomizeCounterLabelUI: PublishSubject<UILabel> { get }
}

protocol OWOnlineViewingUsersCounterViewModelingOutputs {
    var customizeIconImageUI: Observable<UIImageView> { get }
    var customizeCounterLabelUI: Observable<UILabel> { get }
    var viewingCount: Observable<String> { get }
}

protocol OWOnlineViewingUsersCounterViewModeling {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { get }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { get }
}

class OWOnlineViewingUsersCounterViewModel: OWOnlineViewingUsersCounterViewModeling,
                                                OWOnlineViewingUsersCounterViewModelingInputs,
                                                OWOnlineViewingUsersCounterViewModelingOutputs {
    var inputs: OWOnlineViewingUsersCounterViewModelingInputs { return self }
    var outputs: OWOnlineViewingUsersCounterViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeIconImageViewUI = BehaviorSubject<UIImageView?>(value: nil)
    fileprivate let _triggerCustomizeCounterLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeIconImageViewUI = PublishSubject<UIImageView>()
    var triggerCustomizeCounterLabelUI = PublishSubject<UILabel>()

    var customizeIconImageUI: Observable<UIImageView> {
        return _triggerCustomizeIconImageViewUI
            .unwrap()
            .asObservable()
    }

    var customizeCounterLabelUI: Observable<UILabel> {
        return _triggerCustomizeCounterLabelUI
            .unwrap()
            .asObservable()
    }

    lazy var viewingCount: Observable<String> = {
        guard let postId = OWManager.manager.postId else { return .empty() }

        let realtimeService = OWSharedServicesProvider.shared.realtimeService()
        return realtimeService.realtimeData
            .map { realtimeData in
                try? realtimeData.data?.onlineViewingUsersCount("\(OWManager.manager.spotId)_\(postId)")
            }
            .unwrap()
            .map { max($0.count, 1) }
            .map {
                $0.decimalFormatted
            }
            .asObservable()
    }()

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate var model = BehaviorSubject<RealTimeOnlineViewingUsersModel?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWOnlineViewingUsersCounterViewModel {
    func setupObservers() {
        triggerCustomizeIconImageViewUI
            .bind(to: _triggerCustomizeIconImageViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeCounterLabelUI
            .bind(to: _triggerCustomizeCounterLabelUI)
            .disposed(by: disposeBag)
    }
}


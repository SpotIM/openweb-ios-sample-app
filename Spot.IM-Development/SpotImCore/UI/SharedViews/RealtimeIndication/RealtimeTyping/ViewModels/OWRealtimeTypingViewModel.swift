//
//  OWRealtimeTypingViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeTypingViewModelingInputs { }

protocol OWRealtimeTypingViewModelingOutputs {
    var typingCount: Observable<String> { get }
}

protocol OWRealtimeTypingViewModeling {
    var inputs: OWRealtimeTypingViewModelingInputs { get }
    var outputs: OWRealtimeTypingViewModelingOutputs { get }
}

class OWRealtimeTypingViewModel: OWRealtimeTypingViewModeling,
                                 OWRealtimeTypingViewModelingInputs,
                                 OWRealtimeTypingViewModelingOutputs {
    var inputs: OWRealtimeTypingViewModelingInputs { return self }
    var outputs: OWRealtimeTypingViewModelingOutputs { return self }

    lazy var typingCount: Observable<String> = {
        let realtimeIndicatorService = OWSharedServicesProvider.shared.realtimeIndicatorService()
        return realtimeIndicatorService.realtimeIndicatorType
            .map { indicatorType -> String? in
                switch indicatorType {
                case .all(let typingCount, _):
                    return String(typingCount)

                case .typing(let typingCount):
                    let typingString = OWLocalizationManager.shared.localizedString(key: "TypingNow")
                    return String(format: typingString, typingCount)

                default:
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }()
}


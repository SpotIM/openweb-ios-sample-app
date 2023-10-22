//
//  OWRealtimeNewCommentsViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRealtimeNewCommentsViewModelingInputs { }

protocol OWRealtimeNewCommentsViewModelingOutputs {
    var newCommentsText: Observable<String> { get }
}

protocol OWRealtimeNewCommentsViewModeling {
    var inputs: OWRealtimeNewCommentsViewModelingInputs { get }
    var outputs: OWRealtimeNewCommentsViewModelingOutputs { get }
}

class OWRealtimeNewCommentsViewModel: OWRealtimeNewCommentsViewModeling,
                                      OWRealtimeNewCommentsViewModelingInputs,
                                      OWRealtimeNewCommentsViewModelingOutputs {
    var inputs: OWRealtimeNewCommentsViewModelingInputs { return self }
    var outputs: OWRealtimeNewCommentsViewModelingOutputs { return self }

    lazy var newCommentsText: Observable<String> = {
        return realtimeIndicatorService.realtimeIndicatorType
            .map { indicatorType -> String? in
                switch indicatorType {
                case .all(_, let newCommentsCount), .newComments(let newCommentsCount):
                    let newCommentsStringKey = newCommentsCount > 1 ? "ViewNewComments" : "ViewNewComment"
                    let newCommentsString = OWLocalizationManager.shared.localizedString(key: newCommentsStringKey)

                    return String(format: newCommentsString, newCommentsCount)

                default:
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }()

    fileprivate var realtimeIndicatorService: OWRealtimeIndicatorServicing

    init(realtimeIndicatorService: OWRealtimeIndicatorServicing = OWSharedServicesProvider.shared.realtimeIndicatorService()) {
        self.realtimeIndicatorService = realtimeIndicatorService
    }
}

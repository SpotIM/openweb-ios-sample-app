//
//  OWCommunityQuestionViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// TODO: complete
protocol OWCommunityQuestionViewModelingInputs {
    
}

protocol OWCommunityQuestionViewModelingOutputs {
    var communityQuestionString: Observable<String?> { get }
}

protocol OWCommunityQuestionViewModeling {
    var inputs: OWCommunityQuestionViewModelingInputs { get }
    var outputs: OWCommunityQuestionViewModelingOutputs { get }
}

class OWCommunityQuestionViewModel: OWCommunityQuestionViewModeling, OWCommunityQuestionViewModelingInputs, OWCommunityQuestionViewModelingOutputs {
    var inputs: OWCommunityQuestionViewModelingInputs { return self }
    var outputs: OWCommunityQuestionViewModelingOutputs { return self }
    
    fileprivate var queueScheduler: SerialDispatchQueueScheduler = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKCommunityQuestionVMQueue")
    
    var communityQuestionString: Observable<String?> {
        // TODO: get question from conversation!
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .observe(on: queueScheduler)
            .map { config -> String? in
                "Some Question!"
            }
            .unwrap()
            .observe(on: MainScheduler.instance)
            .asObservable()
    }
}

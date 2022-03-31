//
//  OWConversationSummaryViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationSummaryViewModelingInputs { }

protocol OWConversationSummaryViewModelingOutputs {
//    var conversationCommentsCount: Observable<Int> { get }
//    TODO: sort VM
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
}

protocol OWConversationSummaryViewModeling {
    var inputs: OWConversationSummaryViewModelingInputs { get }
    var outputs: OWConversationSummaryViewModelingOutputs { get }
}

class OWConversationSummaryViewModel: OWConversationSummaryViewModeling,
                                      OWConversationSummaryViewModelingInputs,
                                      OWConversationSummaryViewModelingOutputs {
    var inputs: OWConversationSummaryViewModelingInputs { return self }
    var outputs: OWConversationSummaryViewModelingOutputs { return self }
    
    fileprivate let _onlineViewingUsersVM = BehaviorSubject<OWOnlineViewingUsersCounterViewModeling?>(value: nil)
        
    init (onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = OWOnlineViewingUsersCounterViewModel()) {
        self.onlineViewingUsersVM = onlineViewingUsersVM
    }
    
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling
}


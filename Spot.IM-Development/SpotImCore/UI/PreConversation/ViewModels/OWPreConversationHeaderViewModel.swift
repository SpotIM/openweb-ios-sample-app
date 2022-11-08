//
//  OWPreConversationHeaderViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationHeaderViewModelingInputs {
}

protocol OWPreConversationHeaderViewModelingOutputs {
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
    var commentsCount: Observable<String> { get }
}

protocol OWPreConversationHeaderViewModeling {
    var inputs: OWPreConversationHeaderViewModelingInputs { get }
    var outputs: OWPreConversationHeaderViewModelingOutputs { get }
}

class OWPreConversationHeaderViewModel: OWPreConversationHeaderViewModeling, OWPreConversationHeaderViewModelingInputs, OWPreConversationHeaderViewModelingOutputs {
    
    var inputs: OWPreConversationHeaderViewModelingInputs { return self }
    var outputs: OWPreConversationHeaderViewModelingOutputs { return self }
    
    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModelNew()
    }()
    
    var commentsCount: Observable<String> {
        guard let postId = OWManager.manager.postId else { return .empty()}
        
        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { realtimeData in
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(postId)") else {return nil}
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? "(\(count))" : ""
            }
            .asObservable()
    }
}

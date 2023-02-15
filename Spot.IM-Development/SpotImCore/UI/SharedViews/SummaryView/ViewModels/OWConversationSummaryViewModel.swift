//
//  OWConversationSummaryViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationSummaryViewModelingInputs {
    func configure(commentsCount: Int)
}

protocol OWConversationSummaryViewModelingOutputs {
    var conversationCommentsCountText: Observable<String> { get }
    var conversationSortVM: OWConversationSortViewModeling { get }
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

    fileprivate let _commentsCount = BehaviorSubject<Int?>(value: nil)

    init (onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = OWOnlineViewingUsersCounterViewModel(),
          conversationSortVM: OWConversationSortViewModeling = OWConversationSortViewModel()) {
        self.onlineViewingUsersVM = onlineViewingUsersVM
        self.conversationSortVM = conversationSortVM
    }

    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling
    var conversationSortVM: OWConversationSortViewModeling

    var conversationCommentsCountText: Observable<String> {
        _commentsCount
            .unwrap()
            .map {
                let commentsText: String = $0 > 1 ?
                    LocalizationManager.localizedString(key: "Comments") :
                    LocalizationManager.localizedString(key: "Comment")
                return "\($0.formatedCount()) " + commentsText
            }
    }

    func configure(commentsCount: Int) {
        _commentsCount.onNext(commentsCount)
    }
}

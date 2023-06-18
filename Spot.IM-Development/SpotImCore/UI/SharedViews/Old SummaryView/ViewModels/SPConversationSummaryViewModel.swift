//
//  SPConversationSummaryViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol SPConversationSummaryViewModelingInputs {
    func configure(commentsCount: Int)
}

protocol SPConversationSummaryViewModelingOutputs {
    var conversationCommentsCountText: Observable<String> { get }
    var conversationSortVM: SPConversationSortViewModeling { get }
    var onlineViewingUsersVM: SPOnlineViewingUsersCounterViewModeling { get }
}

protocol SPConversationSummaryViewModeling {
    var inputs: SPConversationSummaryViewModelingInputs { get }
    var outputs: SPConversationSummaryViewModelingOutputs { get }
}

class SPConversationSummaryViewModel: SPConversationSummaryViewModeling,
                                      SPConversationSummaryViewModelingInputs,
                                      SPConversationSummaryViewModelingOutputs {
    var inputs: SPConversationSummaryViewModelingInputs { return self }
    var outputs: SPConversationSummaryViewModelingOutputs { return self }

    fileprivate let _commentsCount = BehaviorSubject<Int?>(value: nil)

    init (onlineViewingUsersVM: SPOnlineViewingUsersCounterViewModeling = SPOnlineViewingUsersCounterViewModel(),
          conversationSortVM: SPConversationSortViewModeling = SPConversationSortViewModel()) {
        self.onlineViewingUsersVM = onlineViewingUsersVM
        self.conversationSortVM = conversationSortVM
    }

    var onlineViewingUsersVM: SPOnlineViewingUsersCounterViewModeling
    var conversationSortVM: SPConversationSortViewModeling

    var conversationCommentsCountText: Observable<String> {
        _commentsCount
            .unwrap()
            .map {
                let commentsText: String = $0 > 1 ?
                    SPLocalizationManager.localizedString(key: "Comments") :
                    SPLocalizationManager.localizedString(key: "Comment")
                return "\($0.formatedCount()) " + commentsText
            }
    }

    func configure(commentsCount: Int) {
        _commentsCount.onNext(commentsCount)
    }
}

//
//  ConversationCounterNewAPICellViewModel.swift
//  OpenWeb-Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import OpenWebSDK

protocol ConversationCounterNewAPICellViewModelingInputs {}

protocol ConversationCounterNewAPICellViewModelingOutputs {
    var postId: String { get }
    var comments: Int { get }
    var replies: Int { get }
}

protocol ConversationCounterNewAPICellViewModeling {
    var inputs: ConversationCounterNewAPICellViewModelingInputs { get }
    var outputs: ConversationCounterNewAPICellViewModelingOutputs { get }
}

class ConversationCounterNewAPICellViewModel: ConversationCounterNewAPICellViewModeling,
                                              ConversationCounterNewAPICellViewModelingInputs,
                                              ConversationCounterNewAPICellViewModelingOutputs {
    var inputs: ConversationCounterNewAPICellViewModelingInputs { return self }
    var outputs: ConversationCounterNewAPICellViewModelingOutputs { return self }

    let postId: String
    let comments: Int
    let replies: Int

    init(counter: OWConversationCounter, postId: String) {
        self.postId = postId
        comments = counter.commentsNumber
        replies = counter.repliesNumber
    }
}

//
//  ConversationCounterCellViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 23/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import SpotImCore

protocol ConversationCounterCellViewModelingInputs {}

protocol ConversationCounterCellViewModelingOutputs {
    var postId: String { get }
    var comments: Int { get }
    var replies: Int { get }
}

protocol ConversationCounterCellViewModeling {
    var inputs: ConversationCounterCellViewModelingInputs { get }
    var outputs: ConversationCounterCellViewModelingOutputs { get }
}

class ConversationCounterCellViewModel: ConversationCounterCellViewModeling,
                                            ConversationCounterCellViewModelingInputs,
                                            ConversationCounterCellViewModelingOutputs {
    var inputs: ConversationCounterCellViewModelingInputs { return self }
    var outputs: ConversationCounterCellViewModelingOutputs { return self }
    
    let postId: String
    let comments: Int
    let replies: Int
    
    init(counter: SpotImConversationCounters, postId: String) {
        self.postId = postId
        comments = counter.comments
        replies = counter.replies
    }
}


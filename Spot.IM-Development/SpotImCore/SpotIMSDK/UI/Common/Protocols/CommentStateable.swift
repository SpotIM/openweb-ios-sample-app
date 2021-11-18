//
//  CommentStateable.swift
//  SpotImCore
//
//  Created by Tomer Ben Rachel on 18/11/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

protocol CommentStateable {
    func post()
    func updateCommentText(_ text: String)
    func updateCommentLabels(labelsIds: [String])
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion)
}

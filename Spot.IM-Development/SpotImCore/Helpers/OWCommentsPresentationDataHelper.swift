//
//  OWCommentsPresentationDataHelper.swift
//  SpotImCore
//
//  Created by Alon Shprung on 10/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

class OWCommentsPresentationDataHelper {

    fileprivate static let shared = OWCommentsPresentationDataHelper()

    private init() {}

    static func findVisibleCommentPresentationData(with commentId: OWCommentId, in commentsPresentationData: [OWCommentPresentationData]) -> OWCommentPresentationData? {
        for commentPresentationData in commentsPresentationData {
            if (commentPresentationData.id == commentId) {
                return commentPresentationData
            }
            if let res = findVisibleCommentPresentationData(with: commentId, in: commentPresentationData.repliesPresentation) {
                return res
            }
        }
        return nil
    }
}

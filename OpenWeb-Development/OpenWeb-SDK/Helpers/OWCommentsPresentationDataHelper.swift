//
//  OWCommentsPresentationDataHelper.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 10/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

protocol OWCommentsPresentationDataHelperProtocol {
    func findVisibleCommentPresentationData(
        with commentId: OWCommentId,
        in commentsPresentationData: [OWCommentPresentationData]
    ) -> OWCommentPresentationData?
}

class OWCommentsPresentationDataHelper: OWCommentsPresentationDataHelperProtocol {
    func findVisibleCommentPresentationData(
        with commentId: OWCommentId,
        in commentsPresentationData: [OWCommentPresentationData]
    ) -> OWCommentPresentationData? {
        for commentPresentationData in commentsPresentationData {
            if (commentPresentationData.id == commentId) {
                return commentPresentationData
            }
            // Replies recursion
            if let res = findVisibleCommentPresentationData(with: commentId, in: commentPresentationData.repliesPresentation) {
                return res
            }
        }
        return nil
    }
}

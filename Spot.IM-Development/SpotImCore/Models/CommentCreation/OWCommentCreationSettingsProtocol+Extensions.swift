//
//  OWCommentCreationSettingsProtocol+Extensions.swift
//  SpotImCore
//
//  Created by Alon Haiut on 13/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if NEW_API
extension OWCommentCreationSettingsProtocol {
    public func request(_ request: OWCommentCreationRequestOption) {
        let commentCreationRequestsService = OWSharedServicesProvider.shared.commentCreationRequestsService()
        commentCreationRequestsService.triggerRequest(request)
    }
}
#else
extension OWCommentCreationSettingsProtocol {
    func request(_ request: OWCommentCreationRequestOption) {
        let commentCreationRequestsService = OWSharedServicesProvider.shared.commentCreationRequestsService()
        commentCreationRequestsService.triggerRequest(request)
    }
}
#endif

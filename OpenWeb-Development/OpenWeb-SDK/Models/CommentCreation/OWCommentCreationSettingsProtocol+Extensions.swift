//
//  OWCommentCreationSettingsProtocol+Extensions.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 13/07/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

extension OWCommentCreationSettingsProtocol {
    public func request(_ request: OWCommentCreationRequestOption) {
        let commentCreationRequestsService = OWSharedServicesProvider.shared.commentCreationRequestsService()
        commentCreationRequestsService.triggerRequest(request)
    }
}

//
//  OWCommenterAppealView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 06/08/2025.
//

#if DEBUG
@testable import OpenWebSDK
import Combine
import SnapKit
import UIKit

extension OWAppealRequiredData {
    static func mock() -> OWAppealRequiredData {
        let reasons = [
            OWAppealReason(type: .disagreeGuidelines, requiredAdditionalInfo: false),
            OWAppealReason(type: .dontUnderstandGuidelines, requiredAdditionalInfo: false),
            OWAppealReason(type: .commentFollowsGuidelines, requiredAdditionalInfo: false),
            OWAppealReason(type: .misunderstanding, requiredAdditionalInfo: false),
            OWAppealReason(type: .other, requiredAdditionalInfo: true)
        ]
        
        return OWAppealRequiredData(
            commentId: "mock_comment_id_123",
            reasons: reasons,
            postId: "mock_post_id_456"
        )
    }
}

@available(iOS 17.0, *)
#Preview("Commenter Appeal View") {
    let appealData = OWAppealRequiredData.mock()
    let viewModel = OWCommenterAppealViewVM(
        data: appealData,
        viewableMode: .partOfFlow
    )
    let view = OWCommenterAppealView(viewModel: viewModel)
    view.snp.makeConstraints { make in
        make.width.equalTo(320)
    }
    return view
}

#endif

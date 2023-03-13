//
//  OWCompactCommentViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCompactCommentViewModelingInputs {
}

protocol OWCompactCommentViewModelingOutputs {
    var avatarVM: OWAvatarViewModeling { get }
    var commentType: OWCompactCommentType { get }
    var numberOfLines: Int { get }
}

protocol OWCompactCommentViewModeling {
    var inputs: OWCompactCommentViewModelingInputs { get }
    var outputs: OWCompactCommentViewModelingOutputs { get }
}

class OWCompactCommentViewModel: OWCompactCommentViewModeling,
                                 OWCompactCommentViewModelingInputs,
                                 OWCompactCommentViewModelingOutputs {

    var inputs: OWCompactCommentViewModelingInputs { return self }
    var outputs: OWCompactCommentViewModelingOutputs { return self }

    init(data: OWCommentRequiredData, imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        comment = data.comment
        avatarVM = OWAvatarViewModelV2(user: data.user, imageURLProvider: imageProvider)
        numberOfLines = data.collapsableTextLineLimit
    }

    var avatarVM: OWAvatarViewModeling
    fileprivate var comment: SPComment

    var numberOfLines: Int
    lazy var commentType: OWCompactCommentType = {
        if let commentText = comment.text?.text {
            return .text(string: commentText)
        }
        return .media
    }()
}

enum OWCompactCommentType {
    case text(string: String)
    case media
}


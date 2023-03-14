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

protocol OWPreConversationCompactContentViewModelingInputs {
    var commentData: PublishSubject<OWCommentRequiredData> { get }
}

protocol OWPreConversationCompactContentViewModelingOutputs {
//    var avatarVM: OWAvatarViewModeling { get }
//    var commentType: OWCompactCommentType { get }
//    var numberOfLines: Int { get }
    var contentType: Observable<OWCompactContentType> { get }
}

protocol OWPreConversationCompactContentViewModeling {
    var inputs: OWPreConversationCompactContentViewModelingInputs { get }
    var outputs: OWPreConversationCompactContentViewModelingOutputs { get }
}

class OWPreConversationCompactContentViewModel: OWPreConversationCompactContentViewModeling,
                                 OWPreConversationCompactContentViewModelingInputs,
                                 OWPreConversationCompactContentViewModelingOutputs {

    var inputs: OWPreConversationCompactContentViewModelingInputs { return self }
    var outputs: OWPreConversationCompactContentViewModelingOutputs { return self }

    var commentData = PublishSubject<OWCommentRequiredData>()
    
    fileprivate let _contentType = BehaviorSubject<OWCompactContentType>(value: .skelaton)
    lazy var contentType: Observable<OWCompactContentType> = {
        return _contentType
            .asObservable()
    }()
    
    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        
    }

//    var avatarVM: OWAvatarViewModeling

//    var numberOfLines: Int
//    lazy var commentType: OWCompactCommentType = {
//        if let commentText = comment.text?.text {
//            return .text(string: commentText)
//        }
//        return .media
//    }()
}

enum OWCompactCommentType {
    case text(string: String)
    case media
}

enum OWCompactContentType {
    case comment(type: OWCompactCommentType)
    case emptyConversation
    case closedAndEmpty
    case skelaton
}


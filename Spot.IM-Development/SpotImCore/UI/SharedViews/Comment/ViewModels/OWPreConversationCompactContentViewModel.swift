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
    var avatarVM: OWAvatarViewModeling { get }
//    var commentType: OWCompactCommentType { get }
//    var numberOfLines: Int { get }
    var contentType: Observable<OWCompactContentType> { get }
    var isSkelatonHidden: Observable<Bool> { get }
    var isCommentHidden: Observable<Bool> { get }
    var text: Observable<String> { get }
    var showImagePlaceholder: Observable<Bool> { get }
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
    
    lazy var isSkelatonHidden: Observable<Bool> = {
        contentType
            .map { type in
                if case .skelaton = type {
                    return false
                }
                return true
            }
            .asObservable()
    }()
    
    lazy var isCommentHidden: Observable<Bool> = {
        contentType
            .map { type in
                if case .comment = type {
                    return false
                }
                return true
            }
            .asObservable()
    }()
    
    lazy var showImagePlaceholder: Observable<Bool> = {
        contentType
            .map { type in
                if case .comment(let commentType) = type,
                   case .media = commentType {
                    return true
                }
                return false
            }
    }()

    lazy var text: Observable<String> = {
        contentType
            .map { type in
                switch type {
                case .skelaton:
                    return ""
                case .emptyConversation:
                    return "empty placeolder TODO"
                case .closedAndEmpty:
                    return "closedAndEmpty TODO"
                case .comment(let commentType):
                    switch commentType {
                    case .media:
                        return "Image" // TODO: String
                    case .text(let string):
                        return string
                    }
                }
            }
            .asObservable()
    }()

    fileprivate let imageProvider: OWImageProviding
    fileprivate let disposeBag = DisposeBag()
    init(imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.imageProvider = imageProvider
        setupObservers()
    }

    lazy var avatarVM: OWAvatarViewModeling = {
        return OWAvatarViewModelV2(imageURLProvider: self.imageProvider)
    }()

//    var numberOfLines: Int
//    lazy var commentType: OWCompactCommentType = {
//        if let commentText = comment.text?.text {
//            return .text(string: commentText)
//        }
//        return .media
//    }()
}

fileprivate extension OWPreConversationCompactContentViewModel {
    func setupObservers() {
        commentData
            .subscribe(onNext: { [weak self] requiredData in
                guard let self = self else { return }
                self.avatarVM.inputs.configureUser(user: requiredData.user)

                var commentType: OWCompactCommentType = {
                    if let commentText = requiredData.comment.text?.text {
                        return .text(string: commentText)
                    }
                    return .media
                }()

                self._contentType.onNext(.comment(type: commentType))
            })
            .disposed(by: disposeBag)
    }
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


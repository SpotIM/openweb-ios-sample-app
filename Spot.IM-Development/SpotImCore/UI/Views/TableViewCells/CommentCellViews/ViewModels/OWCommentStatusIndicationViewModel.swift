//
//  OWCommentStatusIndicationViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentStatusIndicationViewModelingInputs {
    func configure(with model: SPComment.CommentStatus)
}

protocol OWCommentStatusIndicationViewModelingOutputs {
    var indicationIcon: Observable<UIImage> { get }
    var indicationText: Observable<String> { get }
    var explanationText: Observable<String> { get }
}

protocol OWCommentStatusIndicationViewModeling {
    var inputs: OWCommentStatusIndicationViewModelingInputs { get }
    var outputs: OWCommentStatusIndicationViewModelingOutputs { get }
}

class OWCommentStatusIndicationViewModel: OWCommentStatusIndicationViewModeling,
                                          OWCommentStatusIndicationViewModelingInputs,
                                          OWCommentStatusIndicationViewModelingOutputs {

    var inputs: OWCommentStatusIndicationViewModelingInputs { return self }
    var outputs: OWCommentStatusIndicationViewModelingOutputs { return self }
        
    fileprivate let _status = BehaviorSubject<SPComment.CommentStatus?>(value: nil)
    
    fileprivate lazy var status: Observable<SPComment.CommentStatus> = {
        self._status
            .unwrap()
    }()
    
    var indicationIcon: Observable<UIImage> {
        self.status
            .map {
                var image: UIImage?
                switch($0) {
                case .reject:
                    image = UIImage(spNamed: "rejectIcon")
                case .requireApproval:
                    image = UIImage(spNamed: "pendingIcon")
                default:
                    image = nil
                }
                return image ?? UIImage()
            }
    }
    
    var indicationText: Observable<String> {
        self.status
            .map {
                switch($0) {
                case .reject:
                    return "Your comment has been rejected"
                case .requireApproval:
                    return "Hold on, your comment is waiting for approval"
                default:
                    return ""
                }
            }
    }
    
    var explanationText: Observable<String> {
        self.status
            .map {
                switch($0) {
                case .reject:
                    return "Your comment has been rejected"
                case .requireApproval:
                    return "Hold on, your comment is waiting for approval"
                default:
                    return ""
                }
            }
    }
    
    func configure(with status: SPComment.CommentStatus) {
        self._status.onNext(status)
    }
}

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
    func configure(with model: SPComment.CommentStatus, isStrictMode: Bool, containerWidth: CGFloat)
}

protocol OWCommentStatusIndicationViewModelingOutputs {
    var indicationIcon: Observable<UIImage> { get }
    var indicationText: Observable<String> { get }
    var indicationHeight: CGFloat { get }
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
    fileprivate let _strictMode = BehaviorSubject<Bool?>(value: nil)
    fileprivate let _commentWidth = BehaviorSubject<CGFloat?>(value: nil)
    
    fileprivate var status: Observable<SPComment.CommentStatus> {
        return self._status.unwrap().asObservable()
    }
    
    fileprivate var strictMode: Observable<Bool> {
        return self._strictMode.unwrap().asObservable()
    }
    
    fileprivate var commentWidth: Observable<CGFloat> {
        return self._commentWidth.unwrap().asObservable()
    }
    
    var indicationIcon: Observable<UIImage> {
        self.status
            .map {
                var image: UIImage?
                switch($0) {
                case .reject, .block:
                    image = UIImage(spNamed: "rejectIcon")
                case .requireApproval, .pending:
                    image = UIImage(spNamed: "pendingIcon")
                default:
                    image = nil
                }
                return image ?? UIImage()
            }
    }
    
    var indicationText: Observable<String> {
        self.status
            .withLatestFrom(strictMode) { [weak self] status, isStrictMode in
                guard let self = self else { return "" }
                return self.indicationText(status: status, isStrictMode: isStrictMode)
            }
    }

    var indicationHeight: CGFloat = 0
    
    func configure(with status: SPComment.CommentStatus, isStrictMode: Bool, containerWidth: CGFloat) {
        self._status.onNext(status)
        self._strictMode.onNext(isStrictMode)
        self._commentWidth.onNext(containerWidth)
        indicationHeight = {
            // calculate text width using the comment with reducing all padding & icon
            let width = containerWidth
                        - (OWCommentStatusIndicationView.Metrics.statusTextHorizontalOffset * 2)
                        - OWCommentStatusIndicationView.Metrics.iconSize
                        - OWCommentStatusIndicationView.Metrics.iconLeadingOffset
            
            let attributedMessage = NSAttributedString(
                string: self.indicationText(status: status, isStrictMode: isStrictMode),
                attributes: [
                    NSAttributedString.Key.font: UIFont.preferred(style: .regular, of: OWCommentStatusIndicationView.Metrics.fontSize)
                ])
            // get the text height and add padding
            let height: CGFloat = attributedMessage.height(withConstrainedWidth: width)
            return height + (OWCommentStatusIndicationView.Metrics.textVerticalPadding * 2)
        }()
    }
}

fileprivate extension OWCommentStatusIndicationViewModel {
    func indicationText(status: SPComment.CommentStatus, isStrictMode: Bool) -> String {
        switch(status) {
        case .reject, .block:
            return LocalizationManager.localizedString(key: "Your comment has been rejected.")
        case .requireApproval, .pending:
            return isStrictMode ?
            LocalizationManager.localizedString(key: "Your comment is waiting for approval due to the site’s policy.") :
            LocalizationManager.localizedString(key: "Hold on, your comment is waiting for approval.")
        default:
            return ""
        }
    }
}

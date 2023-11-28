//
//  UIViewsExamplesViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 21/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

protocol UIViewsExamplesViewModelingInputs {
    var conversationBelowVideoTapped: PublishSubject<Void> { get }
}

protocol UIViewsExamplesViewModelingOutputs {
    var title: String { get }
    var openConversationBelowVideo: Observable<OWPostId> { get }
}

protocol UIViewsExamplesViewModeling {
    var inputs: UIViewsExamplesViewModelingInputs { get }
    var outputs: UIViewsExamplesViewModelingOutputs { get }
}

class UIViewsExamplesViewModel: UIViewsExamplesViewModeling, UIViewsExamplesViewModelingOutputs, UIViewsExamplesViewModelingInputs {
    var inputs: UIViewsExamplesViewModelingInputs { return self }
    var outputs: UIViewsExamplesViewModelingOutputs { return self }

    fileprivate let postId: OWPostId
    fileprivate let disposeBag = DisposeBag()

    let conversationBelowVideoTapped = PublishSubject<Void>()

    fileprivate let _openConversationBelowVideo = BehaviorSubject<OWPostId?>(value: nil)
    var openConversationBelowVideo: Observable<OWPostId> {
        return _openConversationBelowVideo
            .unwrap()
            .asObservable()
    }

    lazy var title: String = {
        return NSLocalizedString("Examples", comment: "")
    }()

    init(postId: OWPostId) {
        self.postId = postId
        setupObservers()
    }
}

fileprivate extension UIViewsExamplesViewModel {
    func setupObservers() {
        conversationBelowVideoTapped
            .asObservable()
            .map { [weak self] _ -> OWPostId? in
                return self?.postId
            }
            .unwrap()
            .bind(to: _openConversationBelowVideo)
            .disposed(by: disposeBag)
    }
}

//
//  OWCommentCreationFooterViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 18/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationFooterViewModelingInputs {
    var tapCta: PublishSubject<Void> { get }
    var tapAction: PublishSubject<Void> { get }
}

protocol OWCommentCreationFooterViewModelingOutputs {
    var ctaTitleText: Observable<String> { get }
    var showAddImageButton: Observable<Bool> { get }
}

protocol OWCommentCreationFooterViewModeling {
    var inputs: OWCommentCreationFooterViewModelingInputs { get }
    var outputs: OWCommentCreationFooterViewModelingOutputs { get }
}

class OWCommentCreationFooterViewModel: OWCommentCreationFooterViewModeling,
                                        OWCommentCreationFooterViewModelingInputs,
                                        OWCommentCreationFooterViewModelingOutputs {

    var inputs: OWCommentCreationFooterViewModelingInputs { return self }
    var outputs: OWCommentCreationFooterViewModelingOutputs { return self }

    var tapCta = PublishSubject<Void>()
    var tapAction = PublishSubject<Void>()

    var ctaTitleText: Observable<String> {
        // TODO
        return Observable.just("Post")
    }

    var showAddImageButton: Observable<Bool> {
        // TODO - Support adding an image
        return Observable.just(false)
    }
}

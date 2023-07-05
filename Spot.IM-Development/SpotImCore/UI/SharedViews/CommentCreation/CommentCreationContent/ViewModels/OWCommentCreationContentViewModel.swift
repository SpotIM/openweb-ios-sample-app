//
//  OWCommentCreationContentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 03/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommentCreationContentViewModelingInputs {
    var commentText: BehaviorSubject<String?> { get }
}

protocol OWCommentCreationContentViewModelingOutputs {
    var commentTextOutput: Observable<String?> { get }
    var showPlaceholder: Observable<Bool> { get }
}

protocol OWCommentCreationContentViewModeling {
    var inputs: OWCommentCreationContentViewModelingInputs { get }
    var outputs: OWCommentCreationContentViewModelingOutputs { get }
}

class OWCommentCreationContentViewModel: OWCommentCreationContentViewModeling,
                                         OWCommentCreationContentViewModelingInputs,
                                         OWCommentCreationContentViewModelingOutputs {

    var inputs: OWCommentCreationContentViewModelingInputs { return self }
    var outputs: OWCommentCreationContentViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding

    var commentText = BehaviorSubject<String?>(value: nil)

    var commentTextOutput: Observable<String?> {
        commentText
            .asObservable()
    }

    var showPlaceholder: Observable<Bool> {
        commentTextOutput
            .map { ($0?.count ?? 0) == 0 }
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

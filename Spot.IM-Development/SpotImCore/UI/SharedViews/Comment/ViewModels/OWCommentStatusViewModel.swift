//
//  OWCommentStatusViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommentStatusViewModelingInputs {
}

protocol OWCommentStatusViewModelingOutputs {
    var iconImage: Observable<UIImage?> { get } // TODO: not null?
}

protocol OWCommentStatusViewModeling {
    var inputs: OWCommentStatusViewModelingInputs { get }
    var outputs: OWCommentStatusViewModelingOutputs { get }
}

class OWCommentStatusViewModel: OWCommentStatusViewModeling,
                                OWCommentStatusViewModelingInputs,
                                OWCommentStatusViewModelingOutputs {

    var inputs: OWCommentStatusViewModelingInputs { return self }
    var outputs: OWCommentStatusViewModelingOutputs { return self }

    fileprivate let _status = BehaviorSubject<OWCommentStatus>(value: .none)

    init (status: OWCommentStatus) {
        _status.onNext(status)
    }

    fileprivate lazy var status: Observable<OWCommentStatus> = {
        self._status
            .asObservable()
    }()

    lazy var iconImage: Observable<UIImage?> = {
        self.status
            .map { status in
                switch(status) {
                case .none: return nil
                case .rejected: return UIImage(spNamed: "verifyIcon", supportDarkMode: false)
                case .pending: return UIImage(spNamed: "verifyIcon", supportDarkMode: false)
                }
            }
    }()
}

enum OWCommentStatus {
    case rejected
    case pending
    case none
}

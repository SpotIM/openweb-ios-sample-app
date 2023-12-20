//
//  OWConversationSizeService.swift
//  SpotImCore
//
//  Created by Refael Sommer on 20/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationSizeServicing {
    var conversationTableWidth: Observable<CGFloat> { get }
    func setConversationTableWidth(width: CGFloat)
}

class OWConversationSizeService: OWConversationSizeServicing {
    fileprivate var _conversationTableWidth = BehaviorSubject<CGFloat>(value: 0)
    var conversationTableWidth: Observable<CGFloat> {
        return _conversationTableWidth
            .asObservable()
    }

    func setConversationTableWidth(width: CGFloat) {
        _conversationTableWidth.onNext(width)
    }
}

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
    var conversationTableSize: Observable<CGSize> { get }
    func setConversationTableSize(_ size: CGSize)
}

class OWConversationSizeService: OWConversationSizeServicing {
    fileprivate var _conversationTableSize = BehaviorSubject<CGSize>(value: .zero)
    var conversationTableSize: Observable<CGSize> {
        return _conversationTableSize
            .asObservable()
    }

    func setConversationTableSize(_ size: CGSize) {
        _conversationTableSize.onNext(size)
    }
}

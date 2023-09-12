//
//  OWToastNotificationService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 12/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWToastNotificationServicing {
    func showToast(presentData: OWToastNotificationPresentData)
    func clearNotifications()

    var toastToShow: Observable<OWToastNotificationPresentData?> { get }
}

class OWToastNotificationService: OWToastNotificationServicing {
    fileprivate let queue = OWQueue<OWToastNotificationPresentData>()

    fileprivate var _toastToShow = BehaviorSubject<OWToastNotificationPresentData?>(value: nil)
    var toastToShow: Observable<OWToastNotificationPresentData?> {
        return _toastToShow
            .asObservable()
    }

    func showToast(presentData: OWToastNotificationPresentData) {
        queue.insert(presentData)
        // Blocking ?
    }

    func clearNotifications() {
        // TODO: should add to OWQueue?
        // Should be called when post changes
    }
}

enum OWToastNotificationDismissStrategy: Codable, Equatable {
    case byUser
    case time(durationMs: Double) // TODO: double?
}

struct OWToastNotificationPresentData: Codable, Equatable {
    let dismissStrategy: OWToastNotificationDismissStrategy
    let data: OWToastRequiredData
    // Show on specific view? all views??
}

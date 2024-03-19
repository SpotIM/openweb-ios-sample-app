//
//  OWToastNotificationCombinedData.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 22/02/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWToastNotificationCombinedData {
    var presentData: OWToastNotificationPresentData
    let actionCompletion: PublishSubject<Void>?

    init(presentData: OWToastNotificationPresentData, actionCompletion: PublishSubject<Void>?) {
        self.presentData = presentData
        self.actionCompletion = actionCompletion
    }
}

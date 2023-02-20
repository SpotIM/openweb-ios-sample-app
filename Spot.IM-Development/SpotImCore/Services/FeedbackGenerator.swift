//
//  FeedbackGenerator.swift
//  SpotImCore
//
//  Created by Eugene on 01.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

typealias FeedbackType = UINotificationFeedbackGenerator.FeedbackType

final class FeedbackGenerator {

    static func generateFeedback(for feedbackType: FeedbackType) {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(feedbackType)
    }

}

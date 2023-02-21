//
//  SPCommentLabelsConfiguration.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

struct SPCommentLabelsSectionConfiguration: Decodable {

    let labels: [SPLabelConfiguration]
    let guidelineText: String
    let maxSelected: Int
    let minSelected: Int

    func getLabelById(labelId: String) -> SPLabelConfiguration? {
        if let label = labels.first(where: { $0.id == labelId }) {
            return label
        }
        return nil
    }
}

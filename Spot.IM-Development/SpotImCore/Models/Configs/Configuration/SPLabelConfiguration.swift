//
//  SPLabelConfiguration.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

struct SPLabelConfiguration: Decodable {

    let id: String
    let text: String
    let color: String
    let iconName: String
    let iconType: String

    func getIconUrl() -> URL? {
        var result = APIConstants.fetchImageBaseURL.appending(SPImageRequestConstants.cloudinaryIconParamString)
        result.append("\(SPImageRequestConstants.fontAwesomePathComponent)\(iconType)-\(iconName).png")
        return URL(string: result)
    }
}

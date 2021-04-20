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
        var result = Constants.cloudinaryBaseURL.appending(Constants.cloudinaryIconParamString)
        result.append("\(Constants.iconPathComponent)\(iconType)-\(iconName).png")
        return URL(string: result)
    }
    
    private enum Constants {
        static let cloudinaryBaseURL = "https://images.spot.im/image/upload/"
        static let cloudinaryIconParamString = "f_png/"
        static let iconPathComponent = "font-awesome/"
    }
}

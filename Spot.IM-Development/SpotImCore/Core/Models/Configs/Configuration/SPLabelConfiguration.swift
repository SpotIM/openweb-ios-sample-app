//
//  SPLabelConfiguration.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 08/04/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

struct SPLabelConfiguration: Decodable {
    
    let id: String?
    let text: String?
    let color: String?
    let iconName: String?
    let iconType: String?
    
    func getIconUrl() -> URL? {
        if let iconName = iconName, let iconType = iconType {
            var result = Constants.cloudinaryBaseURL.appending(Constants.cloudinaryIconParamString)
            // TODO: image size in the url
    //        if let iconSize = iconSize {
    //            result.append("\(Constants.cloudinaryWidthPrefix)" +
    //                "\(Int(iconSize.width))" +
    //                "\(Constants.cloudinaryHeightPrefix)" +
    //                "\(Int(iconSize.height))"
    //            )
    //        }
            
            result.append("\(Constants.iconPathComponent)\(iconType)-\(iconName).png")
            return URL(string: result)
        }
        
        return nil
    }
    
    private enum Constants {
        static let cloudinaryBaseURL = "https://images.spot.im/image/upload/"
        static let cloudinaryWidthPrefix = ",w_"
        static let cloudinaryHeightPrefix = ",h_"
        static let cloudinaryIconParamString = "f_png/"
        static let iconPathComponent = "font-awesome/"
    }
}

//
//  URL+QueryParam.swift
//  SpotImCore
//
//  Created by Oded Regev on 10/05/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

extension URL {

    func appending(_ queryItem: String, value: String?) -> URL {

        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }
    
    func withDarkModeParam() -> URL {
        return self.appending("dark_mode", value: SPUserInterfaceStyle.isDarkMode ? "true" : "false")
    }
}

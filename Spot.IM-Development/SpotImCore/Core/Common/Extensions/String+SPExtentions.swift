//
//  String+SPExtentions.swift
//  SpotImCore
//
//  Created by Alon Shprung on 22/03/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation

extension String {
    var htmlToMutableAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
}

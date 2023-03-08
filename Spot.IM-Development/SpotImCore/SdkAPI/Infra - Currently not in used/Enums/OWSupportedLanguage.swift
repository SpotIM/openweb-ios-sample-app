//
//  OWSupportedLanguage.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

#if NEW_API
public enum OWSupportedLanguage: String {
    case hebrew = "he"
    case english = "en"
    case arabic = "ar"
    case spanish = "es"
    case portoguese = "pt"
    case french = "fr"
}
#else
enum OWSupportedLanguage: String {
    case hebrew = "he"
    case english = "en"
    case arabic = "ar"
    case spanish = "es"
    case portoguese = "pt"
    case french = "fr"
}
#endif

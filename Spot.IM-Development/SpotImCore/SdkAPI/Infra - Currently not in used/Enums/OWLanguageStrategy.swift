//
//  OWLanguageStrategy.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

public enum OWLanguageStrategy: Codable {
    case useDevice // Will be default to English if we don't have translation for this language
    case useServerConfig // Will be default to English if we don't have translation for this language
    case use(language: OWSupportedLanguage)
}

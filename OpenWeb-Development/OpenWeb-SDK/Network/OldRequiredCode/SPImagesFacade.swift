//
//  SPImagesFacade.swift
//  OpenWebSDK
//
//  Created by Andriy Fedin on 06/07/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

internal typealias OWUploadImageResponse = CloudinaryUploadResponse

internal class SPSignResponse: Decodable {
    let signature: String
}

internal class CloudinaryUploadResponse: Decodable {
    let assetId: String
    let width: Int
    let height: Int
}

typealias ImageUploadCompletionHandler = (SPComment.Content.Image?, Error?) -> Void

internal enum SPImageRequestConstants {
    static let cloudinaryApiKey = "281466446316913"
    static let cloudinaryImageParamString = "dpr_3,c_thumb,g_face"
    static let cloudinaryWidthPrefix = ",w_"
    static let cloudinaryHeightPrefix = ",h_"
    static let placeholderImagePrefix = "#"
    static let avatarPathComponent = "avatars/"
    static let imageFileJpegBase64Prefix = "data:image/jpeg;base64,"
    static let cloudinaryIconParamString = "f_png/"
    static let fontAwesomePathComponent = "font-awesome/"
    static let fontAwesomeVersionPathComponent = "v5.15.2/"
    static let iconsPathComponent = "icons/"
    static let customPathComponent = "custom/"
}

//
//  OWImagePickerPresenterResponseType.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 16/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

enum OWImagePickerPresenterResponseType {
    case cancled
    case mediaInfo([UIImagePickerController.InfoKey: AnyObject])
}

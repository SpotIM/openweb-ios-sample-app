//
//  CustomUIDelegate.swift
//  SpotImCore
//
//  Created by Alon Shprung on 01/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol CustomUIDelegate: class {
    func customizeLoginPromptTextView(textView: UITextView)
    func customizeSayControl(labelContainer: BaseView, label: BaseLabel, isPreConversation: Bool)
}

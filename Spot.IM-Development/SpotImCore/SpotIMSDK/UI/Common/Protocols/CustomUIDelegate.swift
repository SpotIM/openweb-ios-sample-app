//
//  CustomUIDelegate.swift
//  SpotImCore
//
//  Created by Alon Shprung on 01/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol CustomUIDelegate: AnyObject {
    func customizeLoginPromptTextView(textView: UITextView)
    func customizeCommunityQuestionTextView(textView: UITextView)
    func customizeSayControl(labelContainer: BaseView, label: BaseLabel, isPreConversation: Bool)
    func customizeConversationFooter(view: UIView)
    func customizeCommunityGuidelines(textView: UITextView)
    func customizeNavigationItemTitle(textView: UITextView)
    func customizeShowCommentsButton(button: SPShowCommentsButton)
    func customizePreConversationHeader(titleLabel: UILabel, counterLabel: UILabel)
    func customizePostCommentButton(button: BaseButton)
}

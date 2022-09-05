//
//  CustomUIDelegate.swift
//  SpotImCore
//
//  Created by Alon Shprung on 01/06/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import UIKit

protocol OWCustomUIDelegate: AnyObject {
    func customizeLoginPromptTextView(textView: UITextView)
    func customizeCommunityQuestionTextView(textView: UITextView)
    func customizeSayControl(labelContainer: UIView, label: UILabel, isPreConversation: Bool)
    func customizeConversationFooter(view: UIView)
    func customizeCommunityGuidelines(textView: UITextView)
    func customizeNavigationItemTitle(label: UILabel)
    func customizeShowCommentsButton(button: SPShowCommentsButton)
    func customizePreConversationHeader(titleLabel: UILabel, counterLabel: UILabel)
    func customizeCommentCreationActionButton(button: OWBaseButton)
    func customizeReadOnlyLabel(label: UILabel)
    func customizeEmptyStateReadOnlyLabel(label: UILabel)
}

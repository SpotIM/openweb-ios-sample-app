//
//  CustomUICallback.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 24/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import UIKit
import OpenWebSDK

enum CustomUICallback {

    static func customize(_ element: OWCustomizableElement, themeStyle: OWThemeStyle) {
        let isDark = themeStyle == .dark

        switch element {
        case .loginPrompt(let element):
            customizeLoginPrompt(element, isDark: isDark)
        case .commentCreationCTA(let element):
            customizeCommentCreationCTA(element, isDark: isDark)
        case .communityQuestion(let element):
            customizeCommunityQuestion(element, isDark: isDark)
        case .summaryHeader(let element):
            customizeSummaryHeader(element)
        case .commentCreationSubmit(let element):
            customizeCommentCreationSubmit(element, isDark: isDark)
        case .commentingEnded(let element):
            customizeCommentingEnded(element)
        case .emptyStateCommentingEnded(let element):
            customizeEmptyStateCommentingEnded(element)
        case .communityGuidelines(let element):
            customizeCommunityGuidelines(element)
        case .header(let element):
            customizeHeader(element, isDark: isDark)
        case .navigation(let element):
            customizeNavigation(element, isDark: isDark)
        case .summary(let element):
            customizeSummary(element, isDark: isDark)
        case .onlineUsers(let element):
            customizeOnlineUsers(element)
        default:
            break
        }
    }
}

// MARK: - Private

private extension CustomUICallback {
    static func customizeLoginPrompt(_ element: OWLoginPromptCustomizableElement, isDark: Bool) {
        switch element {
        case .title(let label):
            label.textColor = .red
            label.textAlignment = .center
        default:
            break
        }
    }

    static func customizeCommentCreationCTA(_ element: OWCommentCreationCTACustomizableElement, isDark: Bool) {
        switch element {
        case .placeholder(let label):
            label.textColor = isDark ? .red : .blue
        default:
            break
        }
    }

    static func customizeCommunityQuestion(_ element: OWCommunityQuestionCustomizableElement, isDark: Bool) {
        switch element {
        case .regular(let label):
            label.textColor = isDark ? .red : .blue
            label.backgroundColor = .gray
        default:
            break
        }
    }

    static func customizeSummaryHeader(_ element: OWSummaryHeaderCustomizableElement) {
        switch element {
        case .title(let label):
            label.text = "Comments"
        default:
            break
        }
    }

    static func customizeCommentCreationSubmit(_ element: OWCommentCreationSubmitCustomizableElement, isDark: Bool) {
        switch element {
        case .button(let button):
            button.backgroundColor = isDark ? .black : .red
        default:
            break
        }
    }

    static func customizeCommentingEnded(_ element: OWCommentingEndedCustomizableElement) {
        switch element {
        case .title(let label):
            label.text = "custom read only"
        default:
            break
        }
    }

    static func customizeEmptyStateCommentingEnded(_ element: OWEmptyStateCommentingEndedCustomizableElement) {
        switch element {
        case .title(let label):
            label.text = "custom empty read only"
        default:
            break
        }
    }

    static func customizeCommunityGuidelines(_ element: OWCommunityGuidelinesCustomizableElement) {
        switch element {
        case .regular(let label):
            label.text = "custom community guidelines"
        default:
            break
        }
    }

    static func customizeHeader(_ element: OWHeaderCustomizableElement, isDark: Bool) {
        switch element {
        case .title(let label):
            label.textColor = isDark ? .white : .black
        default:
            break
        }
    }

    static func customizeNavigation(_ element: OWNavigationCustomizableElement, isDark: Bool) {
        switch element {
        case .navigationBar(let navigationBar):
            navigationBar.backgroundColor = isDark ? .red : .blue
        default:
            break
        }
    }

    static func customizeSummary(_ element: OWSummaryCustomizableElement, isDark: Bool) {
        switch element {
        case .sortByTitle(let label):
            label.textColor = isDark ? .red : .blue
        default:
            break
        }
    }

    static func customizeOnlineUsers(_ element: OWOnlineUsersCustomizableElement) {
        switch element {
        case .counter(let label):
            label.font = UIFont(name: "Georgia", size: label.font.pointSize)
        default:
            break
        }
    }
}

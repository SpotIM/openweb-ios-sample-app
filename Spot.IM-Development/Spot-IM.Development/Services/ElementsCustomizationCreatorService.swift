//
//  ElementsCustomizationCreatorService.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 24/05/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

protocol ElementsCustomizationCreatorServicing {
    static func addElementsCustomization()
}

class ElementsCustomizationCreatorService: ElementsCustomizationCreatorServicing {

    static func addElementsCustomization() {
        let style = UserDefaultsProvider.shared.get(key: .elementsCustomizationStyleIndex, defaultValue: SettingsElementsCustomizationStyle.defaultIndex)
        let customizations = OpenWeb.manager.ui.customizations

        let customizableElement: OWCustomizableElementCallback = { element, source, themeStyle, _ in
            switch style {
            case 1:
                getRevitalStyle(element: element, source: source, themeStyle: themeStyle)
            default:
                break
            }
        }

        customizations.addElementCallback(customizableElement)
    }
}

fileprivate extension ElementsCustomizationCreatorService {

    // swiftlint:disable function_body_length
    static func getRevitalStyle(element: OWCustomizableElement, source: OWViewSourceType, themeStyle: OWThemeStyle) {

//        switch source {
//        case .preConversation:
//            switch element {
//            case .communityQuestionTitle(let label):
//                label.textColor = .red
//            default:
//                break
//            }
//
//        case .conversation:
//            switch element {
//            case .communityQuestionTitle(let label):
//                label.textColor = .green
//            default:
//                break
//            }
//
//        case .commentCreation:
//            break
//        case .commentThread:
//            break
//        default:
//            break
//        }

        switch element {
        case .navigationTitle(label: let label):
            label.text = "TestNavigation"
            label.textColor = .green

        case .articleDescription(let element):
            switch element {
            case .title(let label):
                label.text = "TestArticleTitle"
                label.textColor = .green
            case .author(let label):
                label.text = "TestArticelAuthor"
                label.textColor = .green
            case .image(let imageView):
                switch themeStyle {
                case .dark:
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    imageView.image = UIImage(named: "testIcon")
                default:
                    break
                }
            default:
                break
            }

        case .summeryHeader(element: let element):
            switch element {
            case .counter(let label):
                label.textColor = .blue
                label.text = "TestCounter"
            case.title(let label):
                label.text = "TestSummery"
                label.textColor = .green
            default:
                break
            }

        case .summery(element: let element):
            switch element {
            case .commentsTitle(let label):
                label.text = "TestComments"
                label.textColor = .green
            case .sortByTitle(let label):
                label.text = "TestSortBy"
                label.textColor = .green
            default:
                break
            }

        case .onlineUsers(element: let element):
            switch element {
            case .icon(let imageView):
                switch themeStyle {
                case .dark:
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    imageView.image = UIImage(named: "testIcon")
                default:
                    break
                }

            case .counter(let label):
                label.textColor = .green

            default:
                break
            }

//        case .footer(view: let view):
//            view.backgroundColor = .green

        case .commentCreationCTA(element: let element):
            switch element {
            case .placeholder(let label):
                label.text = "TestPlaceholder"
                label.textColor = .green
            case .container(let view):
                view.backgroundColor = .green
            default:
                break
            }

        case .communityQuestion(let element):
            switch element {
            case .regular(let textView):
                let attributedTitleText = NSMutableAttributedString(string: "TestCommunityGuidelines")
                attributedTitleText.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: attributedTitleText.length))
                textView.attributedText = attributedTitleText
            case .compact(let containerView, let label):
                containerView.backgroundColor = .blue
                label.text = "TestCommunityQuestionCompact"
                label.textColor = .red
            default:
                break
            }

        case .communityGuidelines(let element):
            switch element {
            case .regular(let textView):
                let attributedTitleText = NSMutableAttributedString(string: "TestCommunityGuidelines")
                attributedTitleText.addAttribute(.foregroundColor, value: UIColor.green, range: NSRange(location: 0, length: attributedTitleText.length))
                textView.attributedText = attributedTitleText
            case .compact(let imageView, let textView):
                textView.text = "TestCommunityGuidelinesCompact"
                textView.textColor = .green
                switch themeStyle {
                case .dark:
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    imageView.image = UIImage(named: "testIcon")
                default:
                    break
                }

            default:
                break
            }

        case .emptyState(element: let element):
            switch element {
            case .icon(let imageView):
                switch themeStyle {
                case .dark:
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    imageView.image = UIImage(named: "testIcon")
                default:
                    break
                }
            case .title(let label):
                label.text = "TestEmptyState"
                label.textColor = .green
            default:
                break
            }

        case .commentingEnded(let element):
            switch element {
            case .icon(let imageView):
                switch themeStyle {
                case .dark:
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    imageView.image = UIImage(named: "testIcon")
                default:
                    break
                }
            case .title(let label):
                label.text = "TestCommentingEnded"
                label.textColor = .green
            default:
                break
            }

        default:
            break
        }
    }
    // swiftlint:enable function_body_length
}

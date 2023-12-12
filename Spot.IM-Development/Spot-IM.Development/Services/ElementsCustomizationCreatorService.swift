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
        var customizations = OpenWeb.manager.ui.customizations

        let customizableElement: OWCustomizableElementCallback = { element, source, themeStyle, _ in
            switch style {
            case 1:
                getFirstStyle(element: element, source: source, themeStyle: themeStyle)
            default:
                break
            }
        }

        customizations.addElementCallback(customizableElement)

        switch style {
        case 2:
            customizations.customizedTheme = OWTheme(
                skeletonColor: OWColor(lightColor: .blue, darkColor: .red),
                skeletonShimmeringColor: OWColor(lightColor: .purple, darkColor: .systemPink),
                primarySeparatorColor: OWColor(lightColor: .green, darkColor: .yellow),
                secondarySeparatorColor: OWColor(lightColor: .cyan, darkColor: .magenta),
                tertiarySeparatorColor: OWColor(lightColor: .brown, darkColor: .orange),
                primaryTextColor: OWColor(lightColor: .black, darkColor: .white),
                secondaryTextColor: OWColor(lightColor: .red, darkColor: .blue),
                tertiaryTextColor: OWColor(lightColor: .gray, darkColor: .systemTeal),
                primaryBackgroundColor: OWColor(lightColor: .systemPink, darkColor: .purple),
                secondaryBackgroundColor: OWColor(lightColor: .yellow, darkColor: .green),
                tertiaryBackgroundColor: OWColor(lightColor: .magenta, darkColor: .cyan),
                primaryBorderColor: OWColor(lightColor: .orange, darkColor: .brown),
                secondaryBorderColor: OWColor(lightColor: .white, darkColor: .black),
                loaderColor: OWColor(lightColor: .brown, darkColor: .yellow),
                brandColor: OWColor(lightColor: .cyan, darkColor: .black))
        default:
            break
        }
    }
}

fileprivate extension ElementsCustomizationCreatorService {

    // swiftlint:disable function_body_length
    static func getFirstStyle(element: OWCustomizableElement, source: OWViewSourceType, themeStyle: OWThemeStyle) {

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

        case .navigation(let element):
            switch element {
            case .navigationItem(let navigationItem):
                let lbl = UILabel()
                lbl.textColor = .green
                lbl.font = .italicSystemFont(ofSize: 15.0)
                lbl.text = "TestNavigationItemTitle"
                navigationItem.titleView = lbl
            case .navigationBar(let navigationBar):
                navigationBar.backgroundColor = .blue
                navigationBar.tintColor = .green
            default:
                break
            }

        case .header(let element):
            switch element {
            case .title(let label):
                label.text = "TestNavigation"
                label.textColor = .green
            case .close(let button):
                switch themeStyle {
                case .dark:
                    button.setImage(UIImage(named: "testIcon-dark"), for: .normal)
                case .light:
                    button.setImage(UIImage(named: "testIcon"), for: .normal)
                default:
                    break
                }
            default:
                break
            }

        case .articleDescription(let element):
            switch element {
            case .title(let label):
                label.text = "TestArticleTitle"
                label.textColor = .green
                label.font = UIFont.systemFont(ofSize: 30, weight: .regular)
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

        case .summaryHeader(element: let element):
            switch element {
            case .counter(let label):
                label.textColor = .blue
                label.text = "TestCounter"
            case.title(let label):
                label.text = "TestSummary"
                label.textColor = .green
            default:
                break
            }

        case .summary(element: let element):
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

        case .commentCreationCTA(element: let element):
            switch element {
            case .placeholder(let label):
                label.text = "TestPlaceholder"
                label.textColor = .green
            case .container(let view):
                view.backgroundColor = .blue
            default:
                break
            }

        case .communityQuestion(let element):
            switch element {
            case .regular(let textView):
                let attributedTitleText = NSMutableAttributedString(string: "TestCommunityQuestionRegular")
                attributedTitleText.addAttribute(.foregroundColor,
                                                 value: UIColor.red,
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                attributedTitleText.addAttribute(.font,
                                                 value: UIFont.italicSystemFont(ofSize: 18),
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                textView.attributedText = attributedTitleText
            case .compact(let containerView, let label):
                label.text = "TestCommunityQuestionCompact"
                containerView.backgroundColor = .blue
                label.textColor = .red
            default:
                break
            }

        case .communityGuidelines(let element):
            switch element {
            case .regular(let textView):
                let attributedTitleText = NSMutableAttributedString(string: "TestCommunityGuidelinesRegular")
                attributedTitleText.addAttribute(.foregroundColor,
                                                 value: UIColor.blue,
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                attributedTitleText.addAttribute(.font,
                                                 value: UIFont.systemFont(ofSize: 14, weight: .bold),
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                textView.attributedText = attributedTitleText
            case .compact(let containerView, let imageView, let textView):
                let attributedTitleText = NSMutableAttributedString(string: "TestCommunityGuidelinesCompact")
                attributedTitleText.addAttribute(.foregroundColor,
                                                 value: UIColor.green,
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                attributedTitleText.addAttribute(.font,
                                                 value: UIFont.systemFont(ofSize: 16, weight: .bold),
                                                 range: NSRange(location: 0, length: attributedTitleText.length))
                textView.attributedText = attributedTitleText
                textView.textColor = .green

                switch themeStyle {
                case .dark:
                    containerView.backgroundColor = .gray
                    imageView.image = UIImage(named: "testIcon-dark")
                case .light:
                    containerView.backgroundColor = .darkGray
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

        case .emptyStateCommentingEnded(let element):
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
                label.text = "TestEmptyStateCommentingEnded"
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

        case .commentCreationSubmit(let element):
            switch element {
            case .button(let button):
                button.backgroundColor = .red
                button.tintColor = .green
            default:
                break
            }

        default:
            break
        }
    }
    // swiftlint:enable function_body_length
}

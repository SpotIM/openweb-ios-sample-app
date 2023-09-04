//
//  OWClarityDetailsViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 21/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWClarityDetailsViewViewModelingInputs {
    var closeClick: PublishSubject<Void> { get }
    var gotItClick: PublishSubject<Void> { get }
    var communityGuidelinesClick: PublishSubject<Void> { get }
}

protocol OWClarityDetailsViewViewModelingOutputs {
    var navigationTitle: String { get }
    var detailsTitleText: String { get }
    var bottomParagraphText: String { get }
    var paragraphViewModels: [OWParagraphWithIconViewModeling] { get }
    var dismissView: Observable<Void> { get }
    var topParagraphAttributedStringObservable: Observable<NSAttributedString> { get }
    var communityGuidelinesClickablePlaceholder: String { get }
    var communityGuidelinesClickObservable: Observable<URL> { get }
}

protocol OWClarityDetailsViewViewModeling {
    var inputs: OWClarityDetailsViewViewModelingInputs { get }
    var outputs: OWClarityDetailsViewViewModelingOutputs { get }
}

class OWClarityDetailsViewVM: OWClarityDetailsViewViewModeling,
                                 OWClarityDetailsViewViewModelingInputs,
                              OWClarityDetailsViewViewModelingOutputs {
    var inputs: OWClarityDetailsViewViewModelingInputs { return self }
    var outputs: OWClarityDetailsViewViewModelingOutputs { return self }

    fileprivate let type: OWClarityDetailsType
    fileprivate var disposeBag: DisposeBag
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(type: OWClarityDetailsType, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.type = type
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()

        setupObservers()
    }

    var communityGuidelinesClick = PublishSubject<Void>()
    fileprivate lazy var paragraphsCommunityGuidelinesClick: Observable<Void> = {
        let clickObservers = self.paragraphViewModels
            .map { viewModel in
                viewModel.outputs.communityGuidelinesClickObservable
            }
        return Observable.merge(clickObservers)
    }()
    var communityGuidelinesClickObservable: Observable<URL> {
        return Observable.merge(communityGuidelinesClick, paragraphsCommunityGuidelinesClick)
            .withLatestFrom(communityGuidelinesUrl) { _, url in
                return url
            }
            .unwrap()
            .asObservable()
    }

    var communityGuidelinesClickablePlaceholder = OWLocalizationManager.shared.localizedString(key: "community guidelines").lowercased()

    lazy var navigationTitle: String = {
        switch type {
        case .rejected:
            return "Comment rejected"
        case .pending:
            return OWLocalizationManager.shared.localizedString(key: "Awaiting review")
        }
    }()

    var _topParagraphAttributedString: BehaviorSubject<NSAttributedString?> = BehaviorSubject(value: nil)
    lazy var topParagraphAttributedStringObservable: Observable<NSAttributedString> = {
        return _topParagraphAttributedString
            .unwrap()
            .asObservable()
    }()

    lazy var detailsTitleText: String = {
        switch type {
        case .rejected:
            return "How do we reach our decisions?"
        case .pending:
            return ""
        }
    }()

    lazy var bottomParagraphText: String = {
        switch type {
        case .rejected:
            return ""
        case .pending:
            return "We let registered users know as soon as their comment has been reviewed."
        }
    }()

    // TODO: translations!
    lazy var paragraphViewModels: [OWParagraphWithIconViewModeling] = {
        switch type {
        case .rejected:
            return [
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "heart-icon"),
                    text: "All of our decisions are designed to ensure civil, open and inclusive discourse within the community."),
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "info-icon"),
                    text: "We use advanced machine learning technology combined with unbiased human moderation to review all questionable content."),
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "megaphone-icon"),
                    text: "We do not censor. Our mission is to help build thriving communities and encourage open and civil conversations.")
            ]
        case .pending:
            return [
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "v-icon"),
                    text: "All comments on the site require manual approval (so nothing personal)"),
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "eye-icon"),
                    text: "Certain comments are sent to an internal product performance review (it’s not you, it’s us)"),
                OWParagraphWithIconVM(
                    icon: UIImage(spNamed: "flag-icon"),
                    text: "Your comment has been automatically flagged as it may not align with our community guidelines (You can revise your comment at any time)",
                    communityGuidelinesClickable: true)
            ]
        }
    }()

    var closeClick = PublishSubject<Void>()
    var gotItClick = PublishSubject<Void>()

    lazy var dismissView: Observable<Void> = {
        return Observable.merge(closeClick, gotItClick)
    }()

    lazy private var accessibilityChange: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    fileprivate lazy var communityGuidelinesUrl: Observable<URL?> = {
        let configurationService = servicesProvider.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .take(1)
            .map { [weak self] config -> String? in
                guard let self = self else { return nil }
                guard let conversationConfig = config.conversation,
                          conversationConfig.communityGuidelinesEnabled == true else {
                        return nil
                }
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { communityGuidelines in
                return communityGuidelines.locateURLInText
            }
            .asObservable()
    }()
}

fileprivate extension OWClarityDetailsViewVM {
    func setupObservers() {
        Observable.combineLatest(
            servicesProvider.themeStyleService().style,
            accessibilityChange
        ) { style, _ in
            return style
        }
        .subscribe(onNext: { [weak self] style in
            guard let self = self else { return }
            let attString = self.getTopParagraphAttributedString(clarityType: self.type, style: style)
            self._topParagraphAttributedString.onNext(attString)
        })
        .disposed(by: disposeBag)
    }

    // TODO: translations!
    func getTopParagraphAttributedString(clarityType: OWClarityDetailsType, style: OWThemeStyle) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: OWColorPalette.shared.color(type: .textColor3, themeStyle: style),
            .font: OWFontBook.shared.font(typography: .bodyText)
        ]

        switch clarityType {
        case .rejected:
            let string = "Your comment seems to be in breach of our community guidelines and was therefore rejected. It will only be visible to you."
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
            if let range = string.range(of: communityGuidelinesClickablePlaceholder) {
                let nsRange = NSRange(range, in: string)
                attributedString.addAttribute(.underlineStyle, value: 1, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: OWColorPalette.shared.color(type: .brandColor, themeStyle: style), range: nsRange)
                attributedString.addAttribute(.font, value: OWFontBook.shared.font(typography: .bodyInteraction), range: nsRange)
            }
            return attributedString
        case .pending:
            return NSAttributedString(
                string: OWLocalizationManager.shared.localizedString(key: "ClarityPendingReasonsTitle"),
                attributes: attributes
            )
        }
    }
}

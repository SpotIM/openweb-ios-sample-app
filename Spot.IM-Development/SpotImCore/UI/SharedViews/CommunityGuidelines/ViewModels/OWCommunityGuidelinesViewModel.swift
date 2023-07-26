//
//  OWCommunityGuidelinesViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityGuidelinesViewModelingInputs {
    var triggerCustomizeContainerViewUI: PublishSubject<UIView> { get }
    var triggerCustomizeTitleTextViewUI: PublishSubject<UITextView> { get }
    var triggerCustomizeIconImageViewUI: PublishSubject<UIImageView> { get }
    var urlClicked: PublishSubject<URL> { get }
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var customizeContainerViewUI: Observable<UIView> { get }
    var customizeTitleTextViewUI: Observable<UITextView> { get }
    var customizeIconImageViewUI: Observable<UIImageView> { get }
    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> { get }
    var urlClickedOutput: Observable<URL> { get }
    var shouldShowView: Observable<Bool> { get }
    var showContainer: Bool { get }
    var style: OWCommunityGuidelinesStyle { get }
}

protocol OWCommunityGuidelinesViewModeling {
    var inputs: OWCommunityGuidelinesViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { get }
}

class OWCommunityGuidelinesViewModel: OWCommunityGuidelinesViewModeling,
                                        OWCommunityGuidelinesViewModelingInputs,
                                        OWCommunityGuidelinesViewModelingOutputs {
    struct Metrics {
        static let readOurTitle = OWLocalizationManager.shared.localizedString(key: "Read our")
        static let communityGuidelinesTitle = OWLocalizationManager.shared.localizedString(key: "Community Guidelines").lowercased()
    }

    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeContainerViewUI = BehaviorSubject<UIView?>(value: nil)
    fileprivate let _triggerCustomizeTitleTextViewUI = BehaviorSubject<UITextView?>(value: nil)
    fileprivate let _triggerCustomizeIconImageViewUI = BehaviorSubject<UIImageView?>(value: nil)

    var triggerCustomizeContainerViewUI = PublishSubject<UIView>()
    var triggerCustomizeTitleTextViewUI = PublishSubject<UITextView>()
    var triggerCustomizeIconImageViewUI = PublishSubject<UIImageView>()
    let urlClicked = PublishSubject<URL>()

    var urlClickedOutput: Observable<URL> {
        urlClicked.asObservable()
    }

    var customizeContainerViewUI: Observable<UIView> {
        return _triggerCustomizeContainerViewUI
            .unwrap()
            .asObservable()
    }

    var customizeTitleTextViewUI: Observable<UITextView> {
        return _triggerCustomizeTitleTextViewUI
            .unwrap()
            .asObservable()
    }

    var customizeIconImageViewUI: Observable<UIImageView> {
        return _triggerCustomizeIconImageViewUI
            .unwrap()
            .asObservable()
    }

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        return _shouldShowView
            .unwrap()
            .asObservable()
            .share(replay: 1)
    }

    fileprivate var _communityGuidelinesTitle: Observable<String?> {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .take(1)
            .map { config -> String? in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled == true else { return nil }
                return config.conversation?.communityGuidelinesTitle?.value
            }
    }

    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> {
        return _communityGuidelinesTitle
            .unwrap()
            .observe(on: MainScheduler.asyncInstance)
            .map { [weak self] communityGuidelines in
                guard let self = self else { return nil }
                if self.style == .compact {
                    return self.getCommunityGuidelinesCompactString(communityGuidelinesTitle: communityGuidelines)
                } else {
                    let string = self.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelines)
                    return self.getTitleTextViewAttributedText(htmlString: string)
                }
            }
            .asObservable()
    }

    lazy var showContainer: Bool = {
        return style == .compact
    }()

    let style: OWCommunityGuidelinesStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWCommunityGuidelinesStyle) {
        self.style = style
        setupObservers()
    }
}

fileprivate extension OWCommunityGuidelinesViewModel {
    func setupObservers() {
        _communityGuidelinesTitle
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                let shouldShow = (text != nil) && (self.style != .none)
                self._shouldShowView.onNext(shouldShow)
            })
            .disposed(by: disposeBag)

        triggerCustomizeContainerViewUI
            .bind(to: _triggerCustomizeContainerViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeIconImageViewUI
            .bind(to: _triggerCustomizeIconImageViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeTitleTextViewUI
            .flatMapLatest { [weak self] textView -> Observable<UITextView> in
                guard let self = self else { return .empty() }
                return self.communityGuidelinesHtmlAttributedString
                    .map { _ in return textView }
            }
            .bind(to: _triggerCustomizeTitleTextViewUI)
            .disposed(by: disposeBag)
    }

    func getCommunityGuidelinesHtmlString(communityGuidelinesTitle: String) -> String {
        var htmlString = communityGuidelinesTitle

        // remove <p> and </p> tags to control the text height by the sdk
        htmlString = htmlString.replacingOccurrences(of: "<p>", with: "")
        htmlString = htmlString.replacingOccurrences(of: "</p>", with: "")

        return htmlString
    }

    func getTitleTextViewAttributedText(htmlString: String, url: URL? = nil) -> NSMutableAttributedString? {
        if let htmlMutableAttributedString = htmlString.htmlToMutableAttributedString {

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = OWLocalizationManager.shared.textAlignment

            htmlMutableAttributedString.addAttribute(
                .paragraphStyle,
                value: paragraphStyle,
                range: NSRange(location: 0, length: htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .font,
                value: OWFontBook.shared.font(typography: .bodyText),
                range: NSRange(location: 0, length: htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .foregroundColor,
                value: OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle),
                range: NSRange(location: 0, length: htmlMutableAttributedString.length)
            )

            if let url = url {
                htmlMutableAttributedString.setAsLink(textToFind: Metrics.communityGuidelinesTitle, linkURL: url.absoluteString)
            }

            return htmlMutableAttributedString
        } else {
            return nil
        }
    }

    func getCommunityGuidelinesCompactString(communityGuidelinesTitle: String) -> NSMutableAttributedString? {
        let communityGuidelinesString = Metrics.readOurTitle + " " + Metrics.communityGuidelinesTitle
        let url = communityGuidelinesTitle.locateURLInText
        return self.getTitleTextViewAttributedText(htmlString: communityGuidelinesString, url: url)
    }
}

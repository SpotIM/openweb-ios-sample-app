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
    var urlClicked: PublishSubject<URL> { get }
    var width: BehaviorSubject<CGFloat> { get }
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> { get }
    var urlClickedOutput: Observable<URL> { get }
    var shouldShowViewExternaly: Observable<Bool> { get }
    var shouldShowView: Observable<Bool> { get }
    var showContainer: Bool { get }
    var titleTextViewHeight: Observable<CGFloat> { get }
    var titleTextViewHeightNoneRX: CGFloat { get }
}

protocol OWCommunityGuidelinesViewModeling {
    var inputs: OWCommunityGuidelinesViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { get }
}

class OWCommunityGuidelinesViewModel: OWCommunityGuidelinesViewModeling,
                                        OWCommunityGuidelinesViewModelingInputs,
                                        OWCommunityGuidelinesViewModelingOutputs {
    struct Metrics {
        static let communityGuidelinesFontSize = 15.0
        static let readOurTitle = OWLocalizationManager.shared.localizedString(key: "Read our")
        static let communityGuidelinesTitle = OWLocalizationManager.shared.localizedString(key: "Community Guidelines")
    }

    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }

    let urlClicked = PublishSubject<URL>()

    var urlClickedOutput: Observable<URL> {
        urlClicked.asObservable()
    }

    var titleTextViewHeightNoneRX: CGFloat = 0

    var width = BehaviorSubject<CGFloat>(value: 0)
    fileprivate var widthObservable: Observable<CGFloat> {
        width
            .debug("RIVI widthObservable")
            .distinctUntilChanged()
            .asObservable()
    }

    var titleTextViewHeight: Observable<CGFloat> {
        return Observable.combineLatest(communityGuidelinesHtmlAttributedString.unwrap(),
                                        widthObservable) { htmlString, viewWidth in
            return htmlString.height(withConstrainedWidth: viewWidth)
        }
        .debug("RIVI titleTextViewHeight")
//        .distinctUntilChanged()
        .asObservable()
        .share(replay: 1)
    }

    var shouldShowViewExternaly: Observable<Bool> {
        return Observable.combineLatest(shouldShowView, titleTextViewHeight)
            .map { $0.0 }
            .share()
    }

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        return _shouldShowView
            .debug("RIVI shouldShowView")
            .unwrap()
            .asObservable()
            .share(replay: 1)
//            .distinctUntilChanged()
    }

//    var changeTextViewHeight: Observable<CGFloat> {
//        return isHiddenTextHeightCombine
//            .debug("RIVI changeTextViewHeight")
//            .filter { !$0.0 }
//            .map { $0.1 }
//    }

    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
//            .take(1)
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive,
                                                      internalSerialQueueName: "OpenWebSDKCommunityGuidelinesVMQueue"))
            .map { config -> String? in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled == true else { return nil }
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { [weak self] communityGuidelines in
                guard let self = self else { return nil }
                if self.style == .compact {
                    return self.getCommunityGuidelinesCompactString(communityGuidelinesTitle: communityGuidelines)
                } else {
                    let string = self.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelines)
                    return self.getTitleTextViewAttributedText(htmlString: string)
                }
            }
            .observe(on: MainScheduler.instance)
            .asObservable()
//            .share()
    }

    lazy var showContainer: Bool = {
        return style == .compact
    }()

//    var _isHidden = BehaviorSubject<Bool?>(value: nil)
//    var isHidden: Observable<Bool> {
//        _isHidden
//            .unwrap()
//            .asObservable()
//            .share(replay: 0)
//    }

    fileprivate let style: OWCommunityGuidelinesStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWCommunityGuidelinesStyle) {
        self.style = style
        setupObservers()
    }
}

fileprivate extension OWCommunityGuidelinesViewModel {
    func setupObservers() {
        communityGuidelinesHtmlAttributedString
            .subscribe(onNext: { [weak self] htmlString in
                guard let self = self else { return }
                self._shouldShowView.onNext(htmlString !== nil)
            })
            .disposed(by: disposeBag)

        titleTextViewHeight
            .subscribe(onNext: { [weak self] titleTextViewHeight in
                guard let self = self else { return }
                self.titleTextViewHeightNoneRX = titleTextViewHeight
            })
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
                value: OWFontBook.shared.font(style: .regular, size: Metrics.communityGuidelinesFontSize),
                range: NSRange(location: 0, length: htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .foregroundColor,
                value: OWColorPalette.shared.color(type: .textColor2,
                                                   themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle),
                range: NSRange(location: 0, length: htmlMutableAttributedString.length)
            )

            if let url = url {
                _ = htmlMutableAttributedString.setAsLink(textToFind: Metrics.communityGuidelinesTitle, linkURL: url.absoluteString)
            }

            return htmlMutableAttributedString
        } else {
            return nil
        }
    }

    func getCommunityGuidelinesCompactString(communityGuidelinesTitle: String) -> NSMutableAttributedString? {
        let communityGuidelinesString = Metrics.readOurTitle + " " + Metrics.communityGuidelinesTitle
        let url = locateURLInText(text: communityGuidelinesTitle)
        return self.getTitleTextViewAttributedText(htmlString: communityGuidelinesString, url: url)
    }

    func extractPlainTextFromHTML(html: String) -> String {
        // Remove any HTML tags and convert entities
        let plainText = html.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .removingPercentEncoding ?? html

        var urls = [String]()
        // Remove any URLs
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(location: 0, length: plainText.utf16.count)
            let matches = detector.matches(in: plainText, options: [], range: range)
            urls = matches.map { $0.url!.absoluteString }
        }
        var filteredText = plainText
        for url in urls {
            filteredText = filteredText.replacingOccurrences(of: url, with: "")
        }

        // Trim any leading/trailing whitespace
        return filteredText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func locateURLInText(text: String) -> URL? {
        let linkType: NSTextCheckingResult.CheckingType = [.link]

        var url: URL? = nil
        if let detector = try? NSDataDetector(types: linkType.rawValue) {
            let matches = detector.matches(
                in: text,
                options: [],
                range: NSRange(location: 0, length: text.count)
            )

            for match in matches {
                if let urlMatch = match.url {
                    url = urlMatch
                }
            }
        }

        return url
    }
}

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
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> { get }
    var urlClickedOutput: Observable<URL> { get }
    var shouldShowView: Observable<Bool> { get }
    var showContainer: Bool { get }
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
    }

    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }

    let urlClicked = PublishSubject<URL>()

    var urlClickedOutput: Observable<URL> {
        urlClicked.asObservable()
    }

    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> {
            return OWSharedServicesProvider.shared.spotConfigurationService()
                .config(spotId: OWManager.manager.spotId)
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
                        let communityGuidelinesString = OWLocalizationManager.shared.localizedString(key: "Read our") + " " + OWLocalizationManager.shared.localizedString(key: "Community Guidelines")
                        let string = self.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelinesString)
                        return self.getTitleTextViewAttributedText(htmlString: string)
                    }  else {
                        let string = self.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelines)
                        return self.getTitleTextViewAttributedText(htmlString: string)
                    }
                }
                .observe(on: MainScheduler.instance)
                .asObservable()

    }

    lazy var showContainer: Bool = {
        return style == .compact
    }()

    var _shouldShowView = BehaviorSubject<Bool?>(value: nil)
    var shouldShowView: Observable<Bool> {
        _shouldShowView
            .unwrap()
            .asObservable()
            .share(replay: 0)
    }

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
                if htmlString != nil {
                    self._shouldShowView.onNext(self.style != .none)
                } else {
                    self._shouldShowView.onNext(false)
                }
            }).disposed(by: disposeBag)
    }

    func getCommunityGuidelinesHtmlString(communityGuidelinesTitle: String) -> String {
        var htmlString = communityGuidelinesTitle

        // remove <p> and </p> tags to control the text height by the sdk
        htmlString = htmlString.replacingOccurrences(of: "<p>", with: "")
        htmlString = htmlString.replacingOccurrences(of: "</p>", with: "")

        return htmlString
    }

    func getTitleTextViewAttributedText(htmlString: String) -> NSMutableAttributedString? {
        if let htmlMutableAttributedString = htmlString.htmlToMutableAttributedString {
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
            htmlMutableAttributedString.setAsLink(textToFind: OWLocalizationManager.shared.localizedString(key: "Community Guidelines"), linkURL: "")
            return htmlMutableAttributedString
        } else {
            return nil
        }
    }
}

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
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeIconImageViewUI: PublishSubject<UIImageView> { get }
    var urlClicked: PublishSubject<Void> { get }
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var customizeContainerViewUI: Observable<UIView> { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeIconImageViewUI: Observable<UIImageView> { get }

    var communityGuidelinesAttributedString: Observable<NSAttributedString> { get }
    var communityGuidelinesClickableString: Observable<String> { get }
    var urlClickedOutput: Observable<URL> { get }
    var shouldShowView: Observable<Bool> { get }

    var shouldShowContainer: Bool { get }
    var spacing: CGFloat { get }
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
        static let readOurTitle = OWLocalizationManager.shared.localizedString(key: "ReadOur")
        static let communityGuidelinesTitle = OWLocalizationManager.shared.localizedString(key: "CommunityGuidelines").lowercased()
    }

    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeContainerViewUI = BehaviorSubject<UIView?>(value: nil)
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeIconImageViewUI = BehaviorSubject<UIImageView?>(value: nil)

    var triggerCustomizeContainerViewUI = PublishSubject<UIView>()
    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeIconImageViewUI = PublishSubject<UIImageView>()
    let urlClicked = PublishSubject<Void>()

    fileprivate var _communityGuidelinesUrl = BehaviorSubject<URL?>(value: nil)
    var urlClickedOutput: Observable<URL> {
        urlClicked
            .withLatestFrom(_communityGuidelinesUrl.unwrap()) { _, url in
                return url
            }
            .asObservable()
    }

    var customizeContainerViewUI: Observable<UIView> {
        return _triggerCustomizeContainerViewUI
            .unwrap()
            .asObservable()
    }

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
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

    fileprivate lazy var contentSizeChanged: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    fileprivate var communityGuidelinesTitleFromConfig: Observable<String> {
        let configurationService = OWSharedServicesProvider.shared.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .take(1)
            .map { config -> String? in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled == true else { return nil }
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
    }

    fileprivate var _updateCommunityGuidelinesAttributedString = BehaviorSubject<OWThemeStyle?>(value: nil)
    var communityGuidelinesAttributedString: Observable<NSAttributedString> {
        return Observable.combineLatest(communityGuidelinesTitleFromConfig,
                                _updateCommunityGuidelinesAttributedString)
            .observe(on: MainScheduler.asyncInstance)
            .map { [weak self] communityGuidelinesTitle, themeStyle -> NSAttributedString? in
                guard let self = self else { return nil }
                return self.getAttributedText(style: self.style,
                                              themeStyle: themeStyle,
                                              communityGuidelinesText: communityGuidelinesTitle)
            }
            .unwrap()
    }

    fileprivate var _communityGuidelinesClickableString = PublishSubject<String>()
    var communityGuidelinesClickableString: Observable<String> {
        return _communityGuidelinesClickableString
            .asObservable()
    }

    lazy var shouldShowContainer: Bool = {
        return style == .compact
    }()

    let style: OWCommunityGuidelinesStyle
    let spacing: CGFloat
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    init(style: OWCommunityGuidelinesStyle,
         spacing: CGFloat,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.style = style
        self.spacing = spacing
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWCommunityGuidelinesViewModel {
    func setupObservers() {
        communityGuidelinesAttributedString
            .take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self._shouldShowView.onNext(self.style != .none)
            })
            .disposed(by: disposeBag)

        triggerCustomizeContainerViewUI
            .bind(to: _triggerCustomizeContainerViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeIconImageViewUI
            .bind(to: _triggerCustomizeIconImageViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeTitleLabelUI
            .flatMapLatest { [weak self] label -> Observable<UILabel> in
                guard let self = self else { return .empty() }
                return self.communityGuidelinesAttributedString
                    .map { _ in return label }
            }
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)

        Observable.combineLatest(
            servicesProvider.themeStyleService().style,
            contentSizeChanged) { style, _ in
                return style
            }
            .subscribe(onNext: { [weak self] style in
                guard let self = self else { return }
                self._updateCommunityGuidelinesAttributedString.onNext(style)
            })
            .disposed(by: disposeBag)
    }

    func getAttributedText(style: OWCommunityGuidelinesStyle, themeStyle: OWThemeStyle?, communityGuidelinesText: String) -> NSMutableAttributedString? {
        let currentThemeStyle = themeStyle ?? servicesProvider.themeStyleService().currentStyle

        let communityGuidelinesByStyle = getTextAndLinkedText(style: self.style,
                                                              themeStyle: currentThemeStyle,
                                                              communityGuidelinesText: communityGuidelinesText)
        let url = communityGuidelinesText.locateURLInText
        _communityGuidelinesUrl.onNext(url)

        guard let text = communityGuidelinesByStyle.text,
              let linkedText = communityGuidelinesByStyle.linkedText else { return nil }
        _communityGuidelinesClickableString.onNext(linkedText)

        return text.getAttributedText(textColor: OWColorPalette.shared.color(type: .textColor2, themeStyle: currentThemeStyle),
                                      textFont: OWFontBook.shared.font(typography: .bodyText),
                                      linkedText: linkedText,
                                      linkURL: url,
                                      linkColor: OWColorPalette.shared.color(type: .brandColor, themeStyle: currentThemeStyle),
                                      linkFont: OWFontBook.shared.font(typography: .bodyInteraction),
                                      paragraphAlignment: OWLocalizationManager.shared.textAlignment)
    }

    func getTextAndLinkedText(style: OWCommunityGuidelinesStyle, themeStyle: OWThemeStyle, communityGuidelinesText text: String) -> (text: String?, linkedText: String?) {
        switch style {
        case .compact:
            let compactString = Metrics.readOurTitle + " " + Metrics.communityGuidelinesTitle
            let compactLinkedText = Metrics.communityGuidelinesTitle
            return (compactString, compactLinkedText)
        case .regular:
            let regularString = text.stringWithoutURL
            let regularLinkedText = text.linkedText
            return (regularString, regularLinkedText)
        case .none:
            return (nil, nil)
        }
    }
}

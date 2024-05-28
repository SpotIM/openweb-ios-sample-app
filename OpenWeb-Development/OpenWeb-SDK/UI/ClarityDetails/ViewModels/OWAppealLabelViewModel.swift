//
//  OWAppealLabelViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 31/10/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWAppealLabelViewModelingInputs {
    var appealClick: PublishSubject<Void> { get }
}

protocol OWAppealLabelViewModelingOutputs {
    var viewType: Observable<OWAppealLabelViewType> { get }
    var backgroundColor: Observable<UIColor> { get }
    var borderColor: Observable<UIColor> { get }
    var defaultAttributedText: Observable<NSAttributedString> { get }
    var appealClickableText: String { get }
    var iconImage: Observable<UIImage?> { get }
    var labelAttributedString: Observable<NSAttributedString> { get }
    var openAppeal: Observable<OWAppealRequiredData> { get }
}

protocol OWAppealLabelViewModeling {
    var inputs: OWAppealLabelViewModelingInputs { get }
    var outputs: OWAppealLabelViewModelingOutputs { get }
}

class OWAppealLabelViewModel: OWAppealLabelViewModeling,
                              OWAppealLabelViewModelingInputs,
                              OWAppealLabelViewModelingOutputs {

    var inputs: OWAppealLabelViewModelingInputs { return self }
    var outputs: OWAppealLabelViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    fileprivate var _viewType = BehaviorSubject<OWAppealLabelViewType>(value: .skeleton)
    var viewType: Observable<OWAppealLabelViewType> {
        _viewType
            .asObservable()
    }

    fileprivate var _appealReasons = PublishSubject<Array<OWAppealReason>>()
    fileprivate var appealReasons: Observable<Array<OWAppealReason>> {
        _appealReasons
            .asObservable()
    }

    lazy var borderColor: Observable<UIColor> = {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, theme in
            switch type {
            case .skeleton, .default, .unavailable:
                return OWColorPalette.shared.color(type: .separatorColor3, themeStyle: theme)
            case .error:
                return OWColorPalette.shared.color(type: .errorColor, themeStyle: theme)
            case .none:
                return .clear
            }
        }
    }()

    lazy var backgroundColor: Observable<UIColor> = {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, _ in
            switch type {
            case .skeleton, .default, .unavailable:
                return OWDesignColors.D1
            case .error:
                return .clear
            case .none:
                return .clear
            }
        }
    }()

    lazy private var accessibilityChange: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    let appealClickableText: String = OWLocalizationManager.shared.localizedString(key: "Appeal").lowercased()
    lazy var defaultAttributedText: Observable<NSAttributedString> = {
        Observable.combineLatest(
            servicesProvider.themeStyleService().style,
            accessibilityChange
        ) { [weak self] style, _ in
            guard let self = self else { return nil }
            let string = OWLocalizationManager.shared.localizedString(key: "AppealLabel")
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: OWColorPalette.shared.color(type: .textColor3, themeStyle: style),
                .font: OWFontBook.shared.font(typography: .bodyText)
            ]
            let attributedString = NSMutableAttributedString(string: string, attributes: attributes)
            if let range = string.range(of: self.appealClickableText) {
                let nsRange = NSRange(range, in: string)
                attributedString.addAttribute(.underlineStyle, value: 1, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: OWColorPalette.shared.color(type: .brandColor, themeStyle: style), range: nsRange)
                attributedString.addAttribute(.font, value: OWFontBook.shared.font(typography: .bodyInteraction), range: nsRange)
            }
            return attributedString
        }
        .unwrap()
    }()

    lazy var iconImage: Observable<UIImage?> = {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, _ in
            switch type {
            case .skeleton:
                return nil
            case .default:
                return nil
            case .error:
                return UIImage(spNamed: "appealErrorIcon", supportDarkMode: false)
            case .unavailable:
                return UIImage(spNamed: "appealUnavailableIcon", supportDarkMode: true)
            case .none:
                return nil
            }
        }
    }()

    lazy var labelAttributedString: Observable<NSAttributedString> = {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style,
            accessibilityChange
        ) { type, style, _ -> NSAttributedString? in
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: OWColorPalette.shared.color(type: .textColor3, themeStyle: style),
                .font: OWFontBook.shared.font(typography: .bodyText)
            ]
            switch type {
            case .skeleton:
                return nil
            case .default: // Handeled in different observable for simplicity
                return nil
            case .error:
                return NSAttributedString(
                    string: OWLocalizationManager.shared.localizedString(key: "AppealLabelError"),
                    attributes: [
                        .foregroundColor: OWColorPalette.shared.color(type: .errorColor, themeStyle: style),
                        .font: OWFontBook.shared.font(typography: .bodySpecial)
                    ]
                )
            case .unavailable:
                return NSAttributedString(
                    string: OWLocalizationManager.shared.localizedString(key: "AppealLabelNotAvailable"),
                    attributes: attributes
                )
            case .none:
                return nil
            }
        }
        .unwrap()
    }()

    var appealClick = PublishSubject<Void>()
    var openAppeal: Observable<OWAppealRequiredData> {
        return appealClick
            .withLatestFrom(servicesProvider.authenticationManager().currentAuthenticationLevelAvailability) { [weak self] _, availability -> Bool in
                switch availability {
                case .level(let level):
                    switch level {
                    case .loggedIn:
                        return true
                    default:
                        self?.openNotLogeedInAlert()
                        return false
                    }
                default:
                    return false
                }
            }
            .filter { $0 }
            .withLatestFrom(appealReasons) { [weak self] _, reasons -> OWAppealRequiredData? in
                guard let commentId = self?.commentId else {
                    return nil
                }
                return OWAppealRequiredData(commentId: commentId, reasons: reasons)
            }
            .unwrap()
            .asObservable()
    }

    fileprivate let commentId: OWCommentId
    fileprivate let clarityDetailsType: OWClarityDetailsType
    init(commentId: OWCommentId,
         clarityDetailsType: OWClarityDetailsType,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentId = commentId
        self.clarityDetailsType = clarityDetailsType

        setupObservers()
    }

    // Show view according to config & appeal type
    fileprivate lazy var shouldShowAppealView: Observable<Bool> = {
        let configurationService = servicesProvider.spotConfigurationService()
        return configurationService.config(spotId: OWManager.manager.spotId)
            .take(1)
            .map { [weak self] config -> Bool in
                guard let self = self,
                      let conversationConfig = config.conversation,
                      conversationConfig.isAppealEnabled == true
                else {
                    return false
                }

                return self.clarityDetailsType == .rejected
            }
            .asObservable()
    }()
}

fileprivate extension OWAppealLabelViewModel {
    func setupObservers() {
        shouldShowAppealView
            .subscribe(onNext: { [weak self] shouldShow in
                guard let self else { return }
                if shouldShow {
                    self.fetchEligibleToAppeal()
                } else {
                    self._viewType.onNext(.none)
                }
            })
            .disposed(by: disposeBag)
    }

    func fetchEligibleToAppeal() {
        let viewTypeObservable = servicesProvider.netwokAPI()
            .appeal
            .isEligibleToAppeal(commentId: commentId)
            .response
            .take(1)
            .materialize()
            .map { event in
                switch event {
                case .next(let response):
                    if response.canAppeal {
                        return OWAppealLabelViewType.default
                    } else {
                        return OWAppealLabelViewType.none
                    }
                case .error:
                    return OWAppealLabelViewType.error
                case .completed:
                    return nil
                }
            }
            .unwrap()

        let reasonsObservables = servicesProvider.netwokAPI()
            .appeal
            .getAppealOptions()
            .response
            .materialize()
            .take(1)
            .map { event -> [OWAppealReason]? in
                switch event {
                case .next(let reasons):
                    return reasons
                default:
                    return nil
                }
            }

        Observable.combineLatest(viewTypeObservable, reasonsObservables)
            .subscribe(onNext: { [weak self] type, reasons in
                switch type {
                case .default where reasons == nil:
                    self?._viewType.onNext(.error)
                default:
                    self?._viewType.onNext(type)
                    self?._appealReasons.onNext(reasons ?? [])
                }
            })
            .disposed(by: disposeBag)
    }

    func openNotLogeedInAlert() {
        self.servicesProvider.presenterService()
            .showAlert(
                title: OWLocalizationManager.shared.localizedString(key: "AppealAuthorizationRequiredTitle"),
                message: OWLocalizationManager.shared.localizedString(key: "AppealAuthorizationRequiredMessage"),
                actions: [
                    OWRxPresenterAction(title: "Cancel", type: OWAuthToAppealAlert.cancel),
                    OWRxPresenterAction(title: "Authorize", type: OWAuthToAppealAlert.authenticate)
                ], preferredStyle: .alert, viewableMode: .partOfFlow)
            .map { result -> Bool in
                if case .selected(let action) = result,
                   case OWAuthToAppealAlert.authenticate = action.type {
                    return true
                }
                return false
            }
            .filter { $0 }
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager()
                    .ifNeededTriggerAuthenticationUI(for: .commenterAppeal)
            }
            .flatMapLatest { [weak self] _ -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.authenticationManager().waitForAuthentication(for: .commenterAppeal)
            }
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.appealClick.onNext()
            })
            .disposed(by: disposeBag)
    }
}

enum OWAppealLabelViewType {
    case skeleton
    case `default`
    case error
    case unavailable
    case none
}

enum OWAuthToAppealAlert: String, OWMenuTypeProtocol {
    case cancel
    case authenticate
}

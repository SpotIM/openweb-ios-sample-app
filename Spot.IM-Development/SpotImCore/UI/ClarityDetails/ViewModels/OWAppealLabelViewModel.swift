//
//  OWAppealLabelViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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
    var openAppeal: Observable<Void> { get }
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

    // TODO: API call to get if the user can appeal/did appeal/other info and change _viewType accordingly
    fileprivate var _viewType = BehaviorSubject<OWAppealLabelViewType>(value: .skeleton)
    var viewType: Observable<OWAppealLabelViewType> {
        _viewType
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
            }
        }
    }()

    lazy private var accessibilityChange: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    let appealClickableText: String = "appeal" // TODO: translations
    lazy var defaultAttributedText: Observable<NSAttributedString> = {
        Observable.combineLatest(
            servicesProvider.themeStyleService().style,
            accessibilityChange
        ) { [weak self] style, _ in
            guard let self = self else { return nil }
            let string = "Feel free to rewrite and repost your comment, or, if you wish, you can appeal, and we will re-examine our decision." // TODO: translations
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
                    string: "The appeal information is currently unavailable. Please check your internet connection or try again later.", // TODO: translations
                    attributes: [
                        .foregroundColor: OWColorPalette.shared.color(type: .errorColor, themeStyle: style),
                        .font: OWFontBook.shared.font(typography: .bodySpecial)
                    ]
                )
            case .unavailable:
                return NSAttributedString(
                    string: "The comment you reported is no longer available.", // TODO: translations
                    attributes: attributes
                )
            }
        }
        .unwrap()
    }()

    var appealClick = PublishSubject<Void>()
    var openAppeal: Observable<Void> { // TODO: probably should pass the comment id or something similar
        return appealClick
            .withLatestFrom(servicesProvider.authenticationManager().currentAuthenticationLevelAvailability) { _, availability -> Bool in
                switch availability {
                case .level(let level):
                    switch level {
                    case .loggedIn:
                        return true
                    default:
                        return false
                    }
                default:
                    return false
                }
            }
            .filter { $0 }
            .voidify()
            .asObservable()
    }

    fileprivate let commentId: OWCommentId
    init(commentId: OWCommentId, servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        self.commentId = commentId

        fetchEligibleToAppeal()
    }
}

fileprivate extension OWAppealLabelViewModel {
    func fetchEligibleToAppeal() {
        // TODO: when comment is deleted? unavailable?
        _ = servicesProvider.netwokAPI()
            .appeal
            .isEligibleToAppeal(commentId: commentId)
            .response
            .take(1)
            .subscribe(
                onNext: { [weak self] response in
                    if response.canAppeal {
                        self?._viewType.onNext(.default)
                    }
                    // TODO: do not show label - create none type
            },
                onError: { [weak self] _ in
                    self?._viewType.onNext(.error)
                }
            )
    }
}

enum OWAppealLabelViewType {
    case skeleton
    case `default`
    case error
    case unavailable
}

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
}

protocol OWAppealLabelViewModelingOutputs {
    var viewType: Observable<OWAppealLabelViewType> { get }
    var backgroundColor: Observable<UIColor> { get }
    var borderColor: Observable<UIColor> { get }
    var defaultAttributedText: Observable<NSAttributedString> { get }
    var appealClickableText: String { get }
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

    fileprivate var _viewType = BehaviorSubject<OWAppealLabelViewType>(value: .skeleton)
    var viewType: Observable<OWAppealLabelViewType> {
        _viewType
            .asObservable()
    }

    var borderColor: Observable<UIColor> {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, theme in
            switch type {
            case .skeleton, .appealRejected, .default, .unavailable:
                return OWColorPalette.shared.color(type: .separatorColor3, themeStyle: theme)
            case .error:
                return OWColorPalette.shared.color(type: .errorColor, themeStyle: theme)
            }
        }
    }

    var backgroundColor: Observable<UIColor> {
        Observable.combineLatest(
            viewType,
            servicesProvider.themeStyleService().style
        ) { type, _ in
            switch type {
            case .skeleton, .appealRejected, .default, .unavailable:
                return OWDesignColors.D1
            case .error:
                return .clear
            }
        }
    }

    lazy private var accessibilityChange: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    let appealClickableText: String = "appeal" // TODO: translation
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


    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

enum OWAppealLabelViewType {
    case skeleton
    case appealRejected
    case `default`
    case error
    case unavailable
}

//
//  OWParagraphWithIconVM.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWParagraphWithIconViewModelingInputs {
    var communityGuidelinesClick: PublishSubject<Void> { get }
}

protocol OWParagraphWithIconViewModelingOutputs {
    var icon: UIImage? { get }
    var attributedString: Observable<NSAttributedString> { get }
    var communityGuidelinesClickablePlaceholder: String { get }
    var communityGuidelinesClickObservable: Observable<Void> { get }
}

protocol OWParagraphWithIconViewModeling {
    var inputs: OWParagraphWithIconViewModelingInputs { get }
    var outputs: OWParagraphWithIconViewModelingOutputs { get }
}

class OWParagraphWithIconVM: OWParagraphWithIconViewModeling,
                             OWParagraphWithIconViewModelingInputs,
                             OWParagraphWithIconViewModelingOutputs {

    var inputs: OWParagraphWithIconViewModelingInputs { return self }
    var outputs: OWParagraphWithIconViewModelingOutputs { return self }

    var icon: UIImage?
    private let text: String
    private let communityGuidelinesClickable: Bool

    private var _attributedString: BehaviorSubject<NSAttributedString?> = BehaviorSubject(value: nil)
    lazy var attributedString: Observable<NSAttributedString> = {
        return _attributedString
            .unwrap()
            .asObservable()
    }()
    var communityGuidelinesClickablePlaceholder = OWLocalize.string("CommunityGuidelines").lowercased()

    var communityGuidelinesClick = PublishSubject<Void>()
    var communityGuidelinesClickObservable: Observable<Void> {
        return communityGuidelinesClick
            .asObservable()
    }

    private lazy var accessibilityChange: Observable<Bool> = {
        servicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    private let servicesProvider: OWSharedServicesProviding
    private var disposeBag: DisposeBag

    init(
        icon: UIImage?,
        text: String,
        communityGuidelinesClickable: Bool = false,
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared
    ) {
        self.servicesProvider = servicesProvider
        self.icon = icon
        self.text = text
        self.communityGuidelinesClickable = communityGuidelinesClickable
        self.disposeBag = DisposeBag()

        setupObservers()
    }
}

private extension OWParagraphWithIconVM {
    func setupObservers() {
        Observable.combineLatest(
            servicesProvider.themeStyleService().style,
            accessibilityChange
        ) { style, _ in
            return style
        }
        .subscribe(onNext: { [weak self] style in
            guard let self else { return }
            let attString = self.getAttributedString(style: style)
            self._attributedString.onNext(attString)
        })
        .disposed(by: disposeBag)
    }

    func getAttributedString(style: OWThemeStyle) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: OWColorPalette.shared.color(type: .textColor3, themeStyle: style),
            .font: OWFontBook.shared.font(typography: .bodyText)
        ]

        let attributedString = NSMutableAttributedString(string: self.text, attributes: attributes)

        if self.communityGuidelinesClickable,
           let range = text.range(of: communityGuidelinesClickablePlaceholder) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(.underlineStyle, value: 1, range: nsRange)
            attributedString.addAttribute(.foregroundColor, value: OWColorPalette.shared.color(type: .brandColor, themeStyle: style), range: nsRange)
            attributedString.addAttribute(.font, value: OWFontBook.shared.font(typography: .bodyInteraction), range: nsRange)
        }

        return attributedString
    }
}

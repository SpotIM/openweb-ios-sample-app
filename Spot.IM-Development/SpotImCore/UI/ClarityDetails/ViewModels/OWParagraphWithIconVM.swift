//
//  OWParagraphWithIconVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWParagraphWithIconViewModelingInputs {
}

protocol OWParagraphWithIconViewModelingOutputs {
    var icon: UIImage? { get }
    var attributedString: Observable<NSAttributedString> { get }
    var communityGuidelinesClickablePlaceholder: String { get }
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
    fileprivate let text: String
    fileprivate let communityGuidelinesClickable: Bool

    fileprivate var _attributedString: BehaviorSubject<NSAttributedString?> = BehaviorSubject(value: nil)
    lazy var attributedString: Observable<NSAttributedString> = {
        return _attributedString
            .unwrap()
            .asObservable()
    }()
    var communityGuidelinesClickablePlaceholder = OWLocalizationManager.shared.localizedString(key: "community guidelines").lowercased()

    fileprivate lazy var accessibilityChange: Observable<Bool> = {
        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    fileprivate var disposeBag: DisposeBag
    init(icon: UIImage?, text: String, communityGuidelinesClickable: Bool = false) {
        self.icon = icon
        self.text = text
        self.communityGuidelinesClickable = communityGuidelinesClickable
        self.disposeBag = DisposeBag()

        setupObservers()
    }
}

fileprivate extension OWParagraphWithIconVM {
    func setupObservers() {
        Observable.combineLatest(
            OWSharedServicesProvider.shared.themeStyleService().style, // TODO: inject sharedServicesProvider
            accessibilityChange
        ) { style, _ in
            return style
        }
        .subscribe(onNext: { [weak self] style in
            guard let self = self else { return }
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

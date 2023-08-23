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
}

protocol OWClarityDetailsViewViewModelingOutputs {
    var navigationTitle: String { get }
    var topParagraphAttributedString: NSAttributedString { get }
    var detailsTitleText: String { get }
    var paragraphItems: [OWClarityParagraphItem] { get }
    var dismissView: Observable<Void> { get }
    var topParagraphAttributedStringObservable: Observable<NSAttributedString> { get }
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

    init(type: OWClarityDetailsType) {
        self.type = type
        disposeBag = DisposeBag()

        setupObservers()
    }

    lazy var navigationTitle: String = {
        switch type {
        case .rejected:
            return "Comment rejected"
        case .pending:
            return "Awaiting review"
        }
    }()

    // TODO: translations!
    lazy var topParagraphAttributedString: NSAttributedString = {
        switch type {
        case .rejected:
            let string = "Your comment seems to be in breach of our community guidelines and was therefore rejected. It will only be visible to you."
            let attributedString = NSMutableAttributedString(string: string)
            if let range = string.range(of: "community guidelines") {
                let nsRange = NSRange(range, in: string)
                attributedString.addAttribute(.underlineStyle, value: 1, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light), range: nsRange)
            }
            return attributedString
        case .pending:
            return OWLocalizationManager.shared.localizedString(key: "ClarityPendingReasonsTitle")
                .attributedString
        }
    }()

    var _topParagraphAttributedString: BehaviorSubject<NSAttributedString?> = BehaviorSubject(value: nil) // TODO
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

    // TODO: translations!
    lazy var paragraphItems: [OWClarityParagraphItem] = {
        switch type {
        case .rejected:
            return [
                OWClarityParagraphItem(
                    icon: UIImage(spNamed: "heart-icon"),
                    text: "All of our decisions are designed to ensure civil, open and inclusive discourse within the community."),
                OWClarityParagraphItem(
                    icon: UIImage(spNamed: "info-icon"),
                    text: "We use advanced machine learning technology combined with unbiased human moderation to review all questionable content."),
                OWClarityParagraphItem(
                    icon: UIImage(spNamed: "megaphone-icon"),
                    text: "We do not censor. Our mission is to help build thriving communities and encourage open and civil conversations.")
            ]
        case .pending:
            return []
        }
    }()

    var closeClick = PublishSubject<Void>()
    var gotItClick = PublishSubject<Void>()

    lazy var dismissView: Observable<Void> = {
        return Observable.merge(closeClick, gotItClick)
    }()

    lazy private var accessibilityChange: Observable<Bool> = {
        OWSharedServicesProvider.shared.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()
}

fileprivate extension OWClarityDetailsViewVM {
    func setupObservers() {
        Observable.combineLatest(
            OWSharedServicesProvider.shared.themeStyleService().style, // TODO: inject sharedServicesProvider
            accessibilityChange
        ) { style, _ in
            return style
        }
        .subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let attString = self.getTopParagraphAttributedString(clarityType: self.type)
            self._topParagraphAttributedString.onNext(attString)
        })
        .disposed(by: disposeBag)
    }

    func getTopParagraphAttributedString(clarityType: OWClarityDetailsType) -> NSAttributedString {
        // TODO: add fonts, colors etc
        switch clarityType {
        case .rejected:
            let string = "Your comment seems to be in breach of our community guidelines and was therefore rejected. It will only be visible to you."
            let attributedString = NSMutableAttributedString(string: string)
            if let range = string.range(of: "community guidelines") {
                let nsRange = NSRange(range, in: string)
                attributedString.addAttribute(.underlineStyle, value: 1, range: nsRange)
                attributedString.addAttribute(.foregroundColor, value: OWColorPalette.shared.color(type: .brandColor, themeStyle: .light), range: nsRange)
            }
            return attributedString
        case .pending:
            return OWLocalizationManager.shared.localizedString(key: "ClarityPendingReasonsTitle")
                .attributedString
        }
    }
}

// TODO: new file
struct OWClarityParagraphItem {
    let icon: UIImage?
    let text: String // attributes?
}

//
//  OWErrorStateViewVM.swift
//  SpotImCore
//
//  Created by Refael Sommer on 10/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift
import Foundation

protocol OWErrorStateViewViewModelingInputs {
    var tryAgainTap: PublishSubject<Void> { get }
    var errorStateType: OWErrorStateTypes { get set }
    var heightChange: BehaviorSubject<CGFloat> { get }
}

protocol OWErrorStateViewViewModelingOutputs {
    var title: String { get }
    var tryAgainText: NSAttributedString { get }
    var tryAgainTapped: Observable<OWErrorStateTypes> { get }
    var shouldHaveBorder: Bool { get }
    var height: Observable<CGFloat> { get }
    var errorStateType: OWErrorStateTypes { get }
}

protocol OWErrorStateViewViewModeling {
    var inputs: OWErrorStateViewViewModelingInputs { get }
    var outputs: OWErrorStateViewViewModelingOutputs { get }
}

class OWErrorStateViewViewModel: OWErrorStateViewViewModeling, OWErrorStateViewViewModelingInputs, OWErrorStateViewViewModelingOutputs {
    var inputs: OWErrorStateViewViewModelingInputs { return self }
    var outputs: OWErrorStateViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    var errorStateType: OWErrorStateTypes {
        didSet {
            heightChange.onNext(0)
        }
    }

    init(errorStateType: OWErrorStateTypes) {
        self.errorStateType = errorStateType
    }

    var tryAgainTap = PublishSubject<Void>()
    lazy var tryAgainTapped: Observable<OWErrorStateTypes> = {
        return tryAgainTap
            .map { [weak self] _ -> OWErrorStateTypes? in
                guard let self = self else { return nil }
                return self.errorStateType
            }
            .unwrap()
            .asObservable()
    }()

    lazy var title: String = {
        let key = {
            switch errorStateType {
            case .loadConversationComments, .loadMoreConversationComments:
                return "ErrorStateLoadConversationComments"
            case .loadConversationReplies:
                return "ErrorStateLoadConversationReplies"
            case .none:
                return ""
            }
        }()
        return OWLocalizationManager.shared.localizedString(key: key)
    }()

    lazy var tryAgainText: NSAttributedString = {
        let tryAgainText = OWLocalizationManager.shared.localizedString(key: "TryAgain")
        var attributedString = NSMutableAttributedString(string: tryAgainText)
        attributedString.addAttribute(.font,
                                      value: OWFontBook.shared.font(typography: .bodyInteraction, forceOpenWebFont: false),
                                         range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.underlineStyle,
                                      value: NSUnderlineStyle.single.rawValue,
                                      range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }()

    lazy var shouldHaveBorder: Bool = {
        switch errorStateType {
        case .none, .loadConversationComments:
            return false
        case .loadMoreConversationComments, .loadConversationReplies:
            return true
        }
    }()

    var heightChange = BehaviorSubject<CGFloat>(value: 0)
    var height: Observable<CGFloat> {
        return heightChange
            .asObservable()
    }
}

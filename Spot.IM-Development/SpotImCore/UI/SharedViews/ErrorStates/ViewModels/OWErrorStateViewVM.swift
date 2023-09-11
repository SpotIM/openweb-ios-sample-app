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
    var tryAgainTapped: PublishSubject<Void> { get }
}

protocol OWErrorStateViewViewModelingOutputs {
    var title: String { get }
    var tryAgainText: NSAttributedString { get }
    var tryAgainTap: Observable<OWErrorStateTypes> { get }
}

protocol OWErrorStateViewViewModeling {
    var inputs: OWErrorStateViewViewModelingInputs { get }
    var outputs: OWErrorStateViewViewModelingOutputs { get }
}

class OWErrorStateViewViewModel: OWErrorStateViewViewModeling, OWErrorStateViewViewModelingInputs, OWErrorStateViewViewModelingOutputs {
    var inputs: OWErrorStateViewViewModelingInputs { return self }
    var outputs: OWErrorStateViewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let errorStateType: OWErrorStateTypes

    init(errorStateType: OWErrorStateTypes) {
        self.errorStateType = errorStateType
    }

    var tryAgainTapped = PublishSubject<Void>()
    lazy var tryAgainTap: Observable<OWErrorStateTypes> = {
        return tryAgainTapped
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
            case .loadConversationComments:
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
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.brandColor,
                                         range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.font,
                                      value: OWFontBook.shared.font(typography: .bodyInteraction, forceOpenWebFont: false),
                                         range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }()
}

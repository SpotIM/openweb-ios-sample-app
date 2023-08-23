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
}

protocol OWClarityDetailsViewViewModelingOutputs {
    var navigationTitle: String { get }
    var topParagraphAttributedString: NSAttributedString { get }
    var detailsTitleText: String { get }
    var paragraphItems: [OWClarityParagraphItem] { get }
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

    init(type: OWClarityDetailsType) {
        self.type = type
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
            return "Your comment seems to be in breach of our community guidelines and was therefore rejected. It will only be visible to you."
                .attributedString // TODO: add community guidelines link
        case .pending:
            return OWLocalizationManager.shared.localizedString(key: "ClarityPendingReasonsTitle")
                .attributedString
        }
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

}

// TODO: new file
struct OWClarityParagraphItem {
    let icon: UIImage?
    let text: String // attributes?
}

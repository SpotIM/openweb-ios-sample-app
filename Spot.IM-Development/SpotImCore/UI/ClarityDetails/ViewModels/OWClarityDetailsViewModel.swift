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

protocol OWClarityDetailsViewModelingInputs {
}

protocol OWClarityDetailsViewModelingOutputs {
    var topParagraphAttributedString: NSAttributedString { get }
}

protocol OWClarityDetailsViewModeling {
    var inputs: OWClarityDetailsViewModelingInputs { get }
    var outputs: OWClarityDetailsViewModelingOutputs { get }
}

class OWClarityDetailsViewModel: OWClarityDetailsViewModeling,
                                 OWClarityDetailsViewModelingInputs,
                                 OWClarityDetailsViewModelingOutputs {

    var inputs: OWClarityDetailsViewModelingInputs { return self }
    var outputs: OWClarityDetailsViewModelingOutputs { return self }

    fileprivate var type: OWClarityDetailsType = .rejected // TODO: get in init

    lazy var topParagraphAttributedString: NSAttributedString = {
        switch type {
        case .rejected:
            return "Your comment seems to be in breach of our community guidelines and was therefore rejected. It will only be visible to you."
                .attributedString // TODO: add community guidelines link
        case .pending:
            return "Your comment may have been sent for review for one of the following reasons:"
                .attributedString
        }
    }()

}

// TODO: new file
enum OWClarityDetailsType {
    case rejected
    case pending
}

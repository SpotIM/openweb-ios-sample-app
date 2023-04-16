//
//  OWCommunityGuidelinesCellViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 21/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityGuidelinesCellViewModelingInputs { }

protocol OWCommunityGuidelinesCellViewModelingOutputs {
    var id: String { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
}

protocol OWCommunityGuidelinesCellViewModeling: OWCellViewModel {
    var inputs: OWCommunityGuidelinesCellViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesCellViewModelingOutputs { get }
}

class OWCommunityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling,
                                        OWCommunityGuidelinesCellViewModelingInputs,
                                        OWCommunityGuidelinesCellViewModelingOutputs {
    var inputs: OWCommunityGuidelinesCellViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesCellViewModelingOutputs { return self }

    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel(style: self.style)
    }()

    fileprivate let style: OWCommunityGuidelinesStyle

    // Unique identifier
    let id: String = UUID().uuidString

    init(style: OWCommunityGuidelinesStyle) {
        self.style = style
    }

    init() {
        self.style = .regular
    }
}

extension OWCommunityGuidelinesCellViewModel {
    static func stub() -> OWCommunityGuidelinesCellViewModeling {
        return OWCommunityGuidelinesCellViewModel()
    }
}

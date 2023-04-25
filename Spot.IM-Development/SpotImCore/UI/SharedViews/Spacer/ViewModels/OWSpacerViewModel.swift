//
//  OWSpacerViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 16/04/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWSpacerViewModelingInputs { }

protocol OWSpacerViewModelingOutputs {
    var shouldShowCommunityStyle: Bool { get }
    var shouldShowCommentStyle: Bool { get }
}

protocol OWSpacerViewModeling {
    var inputs: OWSpacerViewModelingInputs { get }
    var outputs: OWSpacerViewModelingOutputs { get }
}

class OWSpacerViewModel: OWSpacerViewModeling,
                         OWSpacerViewModelingInputs,
                         OWSpacerViewModelingOutputs {

    var inputs: OWSpacerViewModelingInputs { return self }
    var outputs: OWSpacerViewModelingOutputs { return self }

    lazy var shouldShowCommunityStyle: Bool = {
        return style == .community
    }()

    lazy var shouldShowCommentStyle: Bool = {
        return style == .comment
    }()

    fileprivate let style: OWSpacerStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWSpacerStyle) {
        self.style = style
    }
}

//
//  OWUserMentionSearchingCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 20/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWUserMentionSearchingCellViewModelingInputs { }

protocol OWUserMentionSearchingCellViewModelingOutputs {
    var id: String { get }
}

protocol OWUserMentionSearchingCellViewModeling: OWCellViewModel {
    var inputs: OWUserMentionSearchingCellViewModelingInputs { get }
    var outputs: OWUserMentionSearchingCellViewModelingOutputs { get }
}

class OWUserMentionSearchingCellViewModel: OWUserMentionSearchingCellViewModeling,
                                           OWUserMentionSearchingCellViewModelingInputs,
                                           OWUserMentionSearchingCellViewModelingOutputs {
    var inputs: OWUserMentionSearchingCellViewModelingInputs { return self }
    var outputs: OWUserMentionSearchingCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWUserMentionSearchingCellViewModel {
    static func stub() -> OWUserMentionSearchingCellViewModeling {
        return OWUserMentionSearchingCellViewModel()
    }
}

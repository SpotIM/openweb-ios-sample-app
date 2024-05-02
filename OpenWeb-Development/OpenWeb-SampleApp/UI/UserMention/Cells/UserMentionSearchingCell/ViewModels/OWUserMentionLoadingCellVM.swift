//
//  OWUserMentionLoadingCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 20/03/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWUserMentionLoadingCellViewModelingInputs { }

protocol OWUserMentionLoadingCellViewModelingOutputs {
    var id: String { get }
}

protocol OWUserMentionLoadingCellViewModeling: OWCellViewModel {
    var inputs: OWUserMentionLoadingCellViewModelingInputs { get }
    var outputs: OWUserMentionLoadingCellViewModelingOutputs { get }
}

class OWUserMentionLoadingCellViewModel: OWUserMentionLoadingCellViewModeling,
                                           OWUserMentionLoadingCellViewModelingInputs,
                                           OWUserMentionLoadingCellViewModelingOutputs {
    var inputs: OWUserMentionLoadingCellViewModelingInputs { return self }
    var outputs: OWUserMentionLoadingCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String = UUID().uuidString
}

extension OWUserMentionLoadingCellViewModel {
    static func stub() -> OWUserMentionLoadingCellViewModeling {
        return OWUserMentionLoadingCellViewModel()
    }
}

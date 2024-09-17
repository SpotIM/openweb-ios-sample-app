//
//  OWUserMentionCellVM.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 26/02/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol OWUserMentionCellViewModelingInputs { }

protocol OWUserMentionCellViewModelingOutputs {
    var id: String { get }
    var userName: Observable<String> { get }
    var displayName: Observable<String> { get }
    var avatarVM: OWAvatarViewModeling { get }
}

protocol OWUserMentionCellViewModeling: OWCellViewModel {
    var inputs: OWUserMentionCellViewModelingInputs { get }
    var outputs: OWUserMentionCellViewModelingOutputs { get }
}

class OWUserMentionCellViewModel: OWUserMentionCellViewModelingInputs,
                           OWUserMentionCellViewModelingOutputs,
                           OWUserMentionCellViewModeling {
    var inputs: OWUserMentionCellViewModelingInputs { return self }
    var outputs: OWUserMentionCellViewModelingOutputs { return self }

    // Unique identifier
    let id: String
    let _userName = BehaviorSubject<String>(value: "")
    let _displayName = BehaviorSubject<String>(value: "")
    let avatarVM: OWAvatarViewModeling

    var userName: Observable<String> {
        return _userName
            .asObservable()
    }

    var displayName: Observable<String> {
        return _displayName
            .asObservable()
    }

    init(user: SPUser, imageProvider: OWImageProviding = OWCloudinaryImageProvider()) {
        self.id = user.id ?? "0"
        self._userName.onNext(user.userName ?? "")
        self._displayName.onNext(user.displayName ?? "")
        self.avatarVM = OWAvatarViewModel(user: user, imageURLProvider: imageProvider)
    }
}

extension OWUserMentionCellViewModel {
    static func stub() -> OWUserMentionCellViewModeling {
        return OWUserMentionCellViewModel(user: SPUser())
    }
}

//
//  OWCommentOptionsViewModel.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 28/05/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommentOptionsViewModelingInputs {
    func update(user: SPUser)
    var isCommentOfActiveUser: BehaviorSubject<Bool> { get }
    var tapButton: PublishSubject<OWUISource> { get }
}

protocol OWCommentOptionsViewModelingOutputs {
    var openMenu: Observable<([OWRxPresenterAction], OWUISource)> { get }
}

protocol OWCommentOptionsViewModeling {
    var inputs: OWCommentOptionsViewModelingInputs { get }
    var outputs: OWCommentOptionsViewModelingOutputs { get }
}

class OWCommentOptionsViewModel: OWCommentOptionsViewModeling,
                                 OWCommentOptionsViewModelingInputs,
                                 OWCommentOptionsViewModelingOutputs {

    var inputs: OWCommentOptionsViewModelingInputs { return self }
    var outputs: OWCommentOptionsViewModelingOutputs { return self }

    private let disposedBag = DisposeBag()
    private let sharedServiceProvider: OWSharedServicesProviding

    private var user: SPUser

    var isCommentOfActiveUser = BehaviorSubject<Bool>(value: false)

    var tapButton = PublishSubject<OWUISource>()
    var openMenu: Observable<([OWRxPresenterAction], OWUISource)> {
        tapButton
            .flatMapLatest { [weak self] view -> Observable<([OWUserAction: Bool], UIView, SPUser)> in
                guard let self = self else { return .empty() }
                let actions: [OWUserAction] = [.deletingComment, .editingComment]
                let authentication = self.sharedServiceProvider.authenticationManager()

                return authentication.userHasAuthenticationLevel(for: actions)
                    .take(1)
                    .map { ($0, view, self.user) }
            }
            .withLatestFrom(isCommentOfActiveUser) { ($0.0, $0.1, $0.2, $1) }
            .map { actionsAuthenticationLevel, view, user, isLoggedInUserComment in
                let allowDeletingComment = actionsAuthenticationLevel[.deletingComment] ?? false
                let allowEditingComment = actionsAuthenticationLevel[.editingComment] ?? false

                var optionsActions: [OWRxPresenterAction] = []
                if !isLoggedInUserComment {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Report"),
                        type: OWCommentOptionsMenu.reportComment)
                    )
                }
                if allowEditingComment && isLoggedInUserComment {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Edit"),
                        type: OWCommentOptionsMenu.editComment)
                    )
                }
                if allowDeletingComment && isLoggedInUserComment {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Delete"),
                        type: OWCommentOptionsMenu.deleteComment)
                    )
                }
                if !isLoggedInUserComment && !user.isAdmin {
                    optionsActions.append(OWRxPresenterAction(
                        title: OWLocalizationManager.shared.localizedString(key: "Mute"),
                        type: OWCommentOptionsMenu.muteUser)
                    )
                }
                return (optionsActions, view)
            }
            .unwrap()
            .asObservable()
    }

    init(data: OWCommentRequiredData,
         sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        user = data.user
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        user = SPUser()
    }

    func update(user: SPUser) {
        self.user = user
    }
}

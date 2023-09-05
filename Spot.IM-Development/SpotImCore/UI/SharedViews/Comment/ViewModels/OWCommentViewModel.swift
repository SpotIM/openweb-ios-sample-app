//
//  OWCommentViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol OWCommentViewModelingInputs {
    func update(comment: OWComment)
    func update(user: SPUser)
}

protocol OWCommentViewModelingOutputs {
    var statusIndicationVM: OWCommentStatusIndicationViewModeling { get }
    var commentActionsVM: OWCommentActionsViewModeling { get }

    var commentHeaderVM: OWCommentHeaderViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var contentVM: OWCommentContentViewModeling { get }
    var commentEngagementVM: OWCommentEngagementViewModeling { get }
    var shouldHideCommentContent: Observable<Bool> { get }

    var comment: OWComment { get }
    var user: SPUser { get }
}

protocol OWCommentViewModeling {
    var inputs: OWCommentViewModelingInputs { get }
    var outputs: OWCommentViewModelingOutputs { get }
}

class OWCommentViewModel: OWCommentViewModeling,
                          OWCommentViewModelingInputs,
                          OWCommentViewModelingOutputs {

    var inputs: OWCommentViewModelingInputs { return self }
    var outputs: OWCommentViewModelingOutputs { return self }

    fileprivate let sharedServiceProvider: OWSharedServicesProviding

    lazy var statusIndicationVM: OWCommentStatusIndicationViewModeling = {
        return OWCommentStatusIndicationViewModel()
    }()

    lazy var commentActionsVM: OWCommentActionsViewModeling = {
        return OWCommentActionsViewModel()
    }()

    var commentHeaderVM: OWCommentHeaderViewModeling
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling
    var contentVM: OWCommentContentViewModeling
    var commentEngagementVM: OWCommentEngagementViewModeling
    var comment: OWComment
    var user: SPUser

    fileprivate let _shouldHideCommentContent = BehaviorSubject<Bool>(value: false)
    var shouldHideCommentContent: Observable<Bool> {
        _shouldHideCommentContent
            .asObservable()
    }

    func update(comment: OWComment) {
        self.comment = comment

        dictateCommentContentVisibility()

        commentHeaderVM.inputs.update(comment: comment)
        commentLabelsContainerVM.inputs.update(comment: comment)
        contentVM.inputs.update(comment: comment)
    }

    func update(user: SPUser) {
        self.user = user

        dictateCommentContentVisibility()

        commentHeaderVM.inputs.update(user: user)
    }

    init(data: OWCommentRequiredData, sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentHeaderVM = OWCommentHeaderViewModel(data: data)
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel(comment: data.comment, section: data.section)
        contentVM = OWCommentContentViewModel(comment: data.comment, lineLimit: data.collapsableTextLineLimit)
        commentEngagementVM = OWCommentEngagementViewModel(comment: data.comment)
        comment = data.comment
        user = data.user
        dictateCommentContentVisibility()
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
        comment = OWComment()
        user = SPUser()
    }
}

fileprivate extension OWCommentViewModel {
    func dictateCommentContentVisibility() {
        let shouldHide = self.user.isMuted || // muted
            self.comment.deleted || // deleted
            self.comment.reported // reported

        self._shouldHideCommentContent.onNext(shouldHide)
    }
}

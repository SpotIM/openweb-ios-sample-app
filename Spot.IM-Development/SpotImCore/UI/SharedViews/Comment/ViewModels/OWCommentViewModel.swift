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
    func update(activeUserId: String?)
}

protocol OWCommentViewModelingOutputs {
    var commentActionsVM: OWCommentActionsViewModeling { get }

    var commentStatusVM: OWCommentStatusViewModeling { get }
    var commentHeaderVM: OWCommentHeaderViewModeling { get }
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling { get }
    var contentVM: OWCommentContentViewModeling { get }
    var commentEngagementVM: OWCommentEngagementViewModeling { get }
    var shouldHideCommentContent: Observable<Bool> { get }
    var shouldShowCommentStatus: Observable<Bool> { get }
    var showBlockingLayoutView: Observable<Bool> { get }
    var heightChanged: Observable<Void> { get }

    var comment: OWComment { get }
    var user: SPUser { get }
    var activeUserId: String? { get }
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

    lazy var commentActionsVM: OWCommentActionsViewModeling = {
        return OWCommentActionsViewModel()
    }()

    var commentStatusVM: OWCommentStatusViewModeling
    var commentHeaderVM: OWCommentHeaderViewModeling
    var commentLabelsContainerVM: OWCommentLabelsContainerViewModeling
    var contentVM: OWCommentContentViewModeling
    var commentEngagementVM: OWCommentEngagementViewModeling
    var comment: OWComment
    var user: SPUser
    var activeUserId: String?

    fileprivate let _shouldHideCommentContent = BehaviorSubject<Bool>(value: false)
    var shouldHideCommentContent: Observable<Bool> {
        _shouldHideCommentContent
            .asObservable()
    }

    fileprivate var _currentActiveUserId = BehaviorSubject<String?>(value: nil)

    var heightChanged: Observable<Void> {
        Observable.merge(
            contentVM.outputs.collapsableLabelViewModel.outputs.height.voidify(),
            shouldShowCommentStatus.voidify()
        )
    }

    var shouldShowCommentStatus: Observable<Bool> {
        Observable.combineLatest(commentStatusVM.outputs.status, _currentActiveUserId) { [weak self] status, activeUserId in
            guard let self = self,
                  let commentUserId = self.comment.userId,
                  activeUserId == commentUserId
            else { return false }

            return status != .none
        }
        .startWith(false)
    }

    var showBlockingLayoutView: Observable<Bool> {
        // Using Observable.merge because in the future we might have more cases where we show disable layout
        Observable.merge(shouldShowCommentStatus)
    }

    func update(comment: OWComment) {
        self.comment = comment

        dictateCommentContentVisibility()

        commentHeaderVM.inputs.update(comment: comment)
        commentLabelsContainerVM.inputs.update(comment: comment)
        contentVM.inputs.update(comment: comment)
        commentStatusVM.inputs.updateStatus(for: comment)
    }

    func update(user: SPUser) {
        self.user = user

        dictateCommentContentVisibility()

        commentHeaderVM.inputs.update(user: user)
    }

    func update(activeUserId: String?) {
        self.activeUserId = activeUserId
        _currentActiveUserId.onNext(activeUserId)
        commentHeaderVM.inputs.update(activeUserId: activeUserId)
    }

    init(data: OWCommentRequiredData, sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        let status = OWCommentStatusType.commentStatus(from: data.comment.status)
        commentStatusVM = OWCommentStatusViewModel(status: status)
        commentHeaderVM = OWCommentHeaderViewModel(data: data)
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel(comment: data.comment, section: data.section)
        contentVM = OWCommentContentViewModel(comment: data.comment, lineLimit: data.collapsableTextLineLimit)
        commentEngagementVM = OWCommentEngagementViewModel(comment: data.comment)
        comment = data.comment
        user = data.user
        activeUserId = data.activeUserId
        _currentActiveUserId.onNext(data.activeUserId)
        dictateCommentContentVisibility()
    }

    init(sharedServiceProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServiceProvider = sharedServiceProvider
        commentHeaderVM = OWCommentHeaderViewModel()
        commentLabelsContainerVM = OWCommentLabelsContainerViewModel()
        contentVM = OWCommentContentViewModel()
        commentEngagementVM = OWCommentEngagementViewModel()
        commentStatusVM = OWCommentStatusViewModel(status: .none)
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

//
//  OWUserNameViewModel.swift
//  SpotImCore
//
//  Created by Alon Shprung on 27/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit

protocol OWUserNameViewModelingInputs {
    func configure(with model: CommentViewModel)

    var tapUserName: PublishSubject<Void> { get }
    var tapMore: PublishSubject<OWUISource> { get }
}

protocol OWUserNameViewModelingOutputs {
    var subscriberBadgeVM: OWUserSubscriberBadgeViewModeling { get }

    var shouldShowDeletedOrReportedMessage: Observable<Bool> { get }
    var nameText: Observable<String> { get }
    var nameTextStyle: Observable<SPFontStyle> { get }
    var subtitleText: Observable<String> { get }
    var dateText: Observable<String> { get }
    var badgeTitle: Observable<String> { get }
    var isUsernameOneRow: Observable<Bool> { get }
    var hiddenCommentReasonText: Observable<String> { get }

    var userNameTapped: Observable<Void> { get }
    var moreTapped: Observable<OWUISource> { get }
}

protocol OWUserNameViewModeling {
    var inputs: OWUserNameViewModelingInputs { get }
    var outputs: OWUserNameViewModelingOutputs { get }
}

class OWUserNameViewModel: OWUserNameViewModeling,
                              OWUserNameViewModelingInputs,
                              OWUserNameViewModelingOutputs {

    var inputs: OWUserNameViewModelingInputs { return self }
    var outputs: OWUserNameViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()

    fileprivate let _model = BehaviorSubject<CommentViewModel?>(value: nil)

    init(user: SPUser?) {
        if let user = user {
            subscriberBadgeVM.inputs.configureUser(user: user)
        }
    }

    var tapUserName = PublishSubject<Void>()
    var tapMore = PublishSubject<OWUISource>()

    let subscriberBadgeVM: OWUserSubscriberBadgeViewModeling = OWUserSubscriberBadgeViewModel()

    var subtitleText: Observable<String> {
        _model
            .unwrap()
            .map({ model -> String? in
                return model.replyingToDisplayName
            })
            .unwrap()
            .map({ $0.isEmpty ? ""
                : OWLocalizationManager.shared.localizedString(key: "To") + " \($0)"
            })
    }

    var dateText: Observable<String> {
        _model
            .unwrap()
            .map({ model in
                let timestamp = model.timestamp ?? ""
                return (model.replyingToDisplayName?.isEmpty ?? true)
                    ? timestamp : " · ".appending(timestamp)
            })
    }

    var badgeTitle: Observable<String> {
        _model
            .unwrap()
            .map({ model -> String in
                return (model.badgeTitle ?? "")
            })
    }

    var nameText: Observable<String> {
        _model
            .unwrap()
            .map({ model -> String in
                return (model.displayName ?? "")
            })
    }

    var nameTextStyle: Observable<SPFontStyle> {
        _model
            .unwrap()
            .map { $0.replyingToCommentId == nil ? .bold : .medium }
    }

    var isUsernameOneRow: Observable<Bool> {
        _model
            .unwrap()
            .map { $0.isUsernameOneRow() }
    }

    var hiddenCommentReasonText: Observable<String> {
        _model
            .unwrap()
            .map { model in
                guard model.isHiddenComment() else { return "" }
                let localizationKey: String
                if (model.isCommentAuthorMuted) {
                    localizationKey = "This user is muted."
                } else if (model.isReported) {
                    localizationKey = "This message was reported."
                } else {
                    localizationKey = "This message was deleted."
                }
                return OWLocalizationManager.shared.localizedString(key: localizationKey)
            }
    }

    var shouldShowDeletedOrReportedMessage: Observable<Bool> {
        _model
            .unwrap()
            .map { $0.isHiddenComment() }
    }

    var userNameTapped: Observable<Void> {
        tapUserName
            .asObservable()
    }

    var moreTapped: Observable<OWUISource> {
        tapMore
            .asObservable()
    }

    func configure(with model: CommentViewModel) {
        _model.onNext(model)
    }
}

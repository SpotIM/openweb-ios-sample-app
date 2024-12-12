//
//  OWCommentStatusViewModel.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 16/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommentStatusViewModelingInputs {
    var learnMoreTap: PublishSubject<Void> { get }
    func updateStatus(for: OWComment)
    var isCommentOfActiveUser: BehaviorSubject<Bool> { get }
}

protocol OWCommentStatusViewModelingOutputs {
    var iconImage: Observable<UIImage> { get }
    var messageAttributedText: Observable<NSAttributedString> { get }
    var learnMoreClickableString: String { get }
    var learnMoreClicked: Observable<OWClarityDetailsType> { get }
    var status: Observable<OWCommentStatusType> { get }
}

protocol OWCommentStatusViewModeling {
    var inputs: OWCommentStatusViewModelingInputs { get }
    var outputs: OWCommentStatusViewModelingOutputs { get }
}

class OWCommentStatusViewModel: OWCommentStatusViewModeling,
                                OWCommentStatusViewModelingInputs,
                                OWCommentStatusViewModelingOutputs {

    var inputs: OWCommentStatusViewModelingInputs { return self }
    var outputs: OWCommentStatusViewModelingOutputs { return self }

    private let _status = BehaviorSubject<OWCommentStatusType>(value: .none)
    private let commentId: OWCommentId

    private let sharedServicesProvider: OWSharedServicesProviding
    private let disposeBag = DisposeBag()

    init (status: OWCommentStatusType, commentId: OWCommentId, sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServicesProvider = sharedServicesProvider
        self.commentId = commentId
        _status.onNext(status)

        setupObservers()
    }

    lazy var status: Observable<OWCommentStatusType> = {
        self._status
            .asObservable()
    }()

    var isCommentOfActiveUser = BehaviorSubject<Bool>(value: true)

    lazy var iconImage: Observable<UIImage> = {
        Observable.combineLatest(
            status,
            sharedServicesProvider.themeStyleService().style) { [weak self] status, _ in
                switch status {
                case .none: return nil
                case .rejected: return UIImage(spNamed: "rejectedIcon", supportDarkMode: false)
                case .pending: return UIImage(spNamed: "pendingIcon", supportDarkMode: true)
                case .appealed: return UIImage(spNamed: "appealIcon", supportDarkMode: true)
                case .appealRejected: return UIImage(spNamed: "appealRejectedIcon", supportDarkMode: false)
                }
        }
            .unwrap()
    }()

    let learnMoreClickableString = OWLocalize.string("LearnMore")

    lazy private var accessibilityChange: Observable<Bool> = {
        sharedServicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    var messageAttributedText: Observable<NSAttributedString> {
        Observable.combineLatest(
            status,
            isCommentOfActiveUser,
            sharedServicesProvider.themeStyleService().style,
            accessibilityChange) { [weak self] status, isCommentOfActiveUser, style, _ in
                guard let self else { return nil }
                let messageString: String
                switch status {
                case .rejected: messageString = OWLocalize.string("RejectedCommentStatusMessage")
                case .appealed: messageString = OWLocalize.string("AppealedCommentStatusMessage")
                case .appealRejected: messageString = OWLocalize.string("AppealRejectedCommentStatusMessage")
                case .pending: messageString = isCommentOfActiveUser ?
                    OWLocalize.string("PendingCommentStatusMessage") :
                    OWLocalize.string("NotAuthorPendingCommentStatusMessage")
                case .none: return nil
                }

                let messageAttributedString = (messageString + " ")
                    .attributedString
                    .font(OWFontBook.shared.font(typography: .footnoteText))
                    .color(OWColorPalette.shared.color(type: .textColor3, themeStyle: style))

                if status.showLearnMore && isCommentOfActiveUser {
                    let learnMoreAttributedString = self.learnMoreClickableString
                        .attributedString
                        .underline(1)
                        .font(OWFontBook.shared.font(typography: .footnoteLink))
                        .color(OWColorPalette.shared.color(type: .brandColor, themeStyle: style))

                    messageAttributedString.append(learnMoreAttributedString)
                }

                return messageAttributedString
        }
            .unwrap()
    }

    var learnMoreTap = PublishSubject<Void>()
    var learnMoreClicked: Observable<OWClarityDetailsType> {
        return learnMoreTap
            .withLatestFrom(status) { _, status in
                return status
            }
            .map { status -> OWClarityDetailsType? in
                switch status {
                case .rejected, .appealRejected:
                    return OWClarityDetailsType.rejected
                case .pending:
                    return OWClarityDetailsType.pending
                case .none, .appealed:
                    return nil
                }
            }
            .unwrap()
            .asObservable()
    }

    func updateStatus(for comment: OWComment) {
        let newStatus = OWCommentStatusType.commentStatus(from: comment)
        self._status.onNext(newStatus)
    }
}

private extension OWCommentStatusViewModel {
    func setupObservers() {
        sharedServicesProvider.commentStatusUpdaterService()
            .statusUpdate
            .filter { [weak self] commentId, _ in
                guard let self else { return false }
                return commentId == self.commentId
            }
            .subscribe(onNext: { [weak self] _, status in
                self?._status.onNext(status)
            })
            .disposed(by: disposeBag)
    }
}

enum OWCommentStatusType {
    case rejected
    case pending
    case appealed
    case appealRejected
    case none

    static func commentStatus(from comment: OWComment) -> OWCommentStatusType {
        guard let status = comment.status,
              comment.published == false
        else { return .none }

        switch status {
        case .block, .reject:
            return .rejected
        case .pending, .requireApproval:
            return .pending
        case .publishAndModerate, .unknown, .approve, .approveAll, .forceApproveAll:
            return .none
        }
    }

    var showLearnMore: Bool {
        switch self {
        case .rejected, .appealRejected, .pending:
            return true
        case .appealed, .none:
            return false
        }
    }
}

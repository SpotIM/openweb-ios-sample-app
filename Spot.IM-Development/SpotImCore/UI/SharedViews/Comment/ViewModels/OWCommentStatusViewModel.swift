//
//  OWCommentStatusViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 16/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

protocol OWCommentStatusViewModelingInputs {
    var learnMoreTap: PublishSubject<Void> { get }
    func updateStatus(for: OWComment)
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

    fileprivate let _status = BehaviorSubject<OWCommentStatusType>(value: .none)
    fileprivate let commentId: OWCommentId

    fileprivate let sharedServicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

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

    lazy var iconImage: Observable<UIImage> = {
        Observable.combineLatest(
            status,
            sharedServicesProvider.themeStyleService().style) { [weak self] status, _ in
                switch(status) {
                case .none: return nil
                case .rejected: return UIImage(spNamed: "rejectedIcon", supportDarkMode: false)
                case .pending: return UIImage(spNamed: "pendingIcon", supportDarkMode: true)
                }
            }
            .unwrap()
    }()

    let learnMoreClickableString = OWLocalizationManager.shared.localizedString(key: "LearnMore")

    lazy private var accessibilityChange: Observable<Bool> = {
        sharedServicesProvider.appLifeCycle()
            .didChangeContentSizeCategory
            .map { true }
            .startWith(false)
    }()

    var messageAttributedText: Observable<NSAttributedString> {
        Observable.combineLatest(
            status,
            sharedServicesProvider.themeStyleService().style,
            accessibilityChange) { [weak self] status, style, _ in
                guard let self = self else { return nil }
                let messageString: String
                switch(status) {
                case .rejected: messageString = OWLocalizationManager.shared.localizedString(key: "RejectedCommentStatusMessage")
                case .pending: messageString = OWLocalizationManager.shared.localizedString(key: "PendingCommentStatusMessage")
                case .none: return nil
                }

                let messageAttributedString = (messageString + " ")
                    .attributedString
                    .font(OWFontBook.shared.font(typography: .footnoteText))
                    .color(OWColorPalette.shared.color(type: .textColor3, themeStyle: style))

                let learnMoreAttributedString = self.learnMoreClickableString
                    .attributedString
                    .underline(1)
                    .font(OWFontBook.shared.font(typography: .footnoteLink))
                    .color(OWColorPalette.shared.color(type: .brandColor, themeStyle: style))

                messageAttributedString.append(learnMoreAttributedString)

                return messageAttributedString
            }
            .unwrap()
    }

    var learnMoreTap = PublishSubject<Void>()
    var learnMoreClicked: Observable<OWClarityDetailsType> {
        return learnMoreTap
            .withLatestFrom(status) { (_, status) in
                return status
            }
            .map { status -> OWClarityDetailsType? in
                switch status {
                case .rejected:
                    return OWClarityDetailsType.rejected
                case .pending:
                    return OWClarityDetailsType.pending
                case .none:
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

fileprivate extension OWCommentStatusViewModel {
    func setupObservers() {
        sharedServicesProvider.commentStatusUpdaterService()
            .statusUpdate
            .filter { [weak self] commentId, _ in
                guard let self = self else { return false }
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
}

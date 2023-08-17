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
}

protocol OWCommentStatusViewModelingOutputs {
    var iconImage: Observable<UIImage?> { get } // TODO: not null?
    var messageAttributedText: Observable<NSAttributedString> { get }
    var learnMoreClickableString: String { get }
    var learnMoreClicked: Observable<Void> { get }
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

    fileprivate let _status = BehaviorSubject<OWCommentStatus>(value: .none)

    fileprivate let sharedServicesProvider: OWSharedServicesProviding

    init (status: OWCommentStatus, sharedServicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.sharedServicesProvider = sharedServicesProvider
        _status.onNext(status)
    }

    fileprivate lazy var status: Observable<OWCommentStatus> = {
        self._status
            .asObservable()
    }()

    lazy var iconImage: Observable<UIImage?> = {
        Observable.combineLatest(
            status,
            sharedServicesProvider.themeStyleService().style) { [weak self] status, _ in
                switch(status) {
                case .none: return nil
                case .rejected: return UIImage(spNamed: "rejectedIcon", supportDarkMode: false)
                case .pending: return UIImage(spNamed: "pendingIcon", supportDarkMode: true)
                }
            }
    }()

    let learnMoreClickableString = OWLocalizationManager.shared.localizedString(key: "Learn more")

    var messageAttributedText: Observable<NSAttributedString> {
        // TODO: subdcribe also for accesability change
        Observable.combineLatest(
            status,
            sharedServicesProvider.themeStyleService().style,
            sharedServicesProvider.appLifeCycle().didChangeContentSizeCategory) { [weak self] status, style, _ in
                guard let self = self else { return nil }
                let messageString: String
                switch(status) {
                case .rejected: messageString = OWLocalizationManager.shared.localizedString(key: "Your comment was rejected.")
                case .pending: messageString = OWLocalizationManager.shared.localizedString(key: "Hold on, your comment is waiting for approval.")
                case .none: return nil
                }

                let messageAttributedString = (messageString + " ")
                    .attributedString
                    .font(OWFontBook.shared.font(typography: .footnoteText))
                    .color(OWColorPalette.shared.color(type: .textColor3, themeStyle: style))

                let learnMoreAttributedString = self.learnMoreClickableString
                    .attributedString
                    .underline(1)
                    .font(OWFontBook.shared.font(typography: .footnoteText))
                    .color(OWColorPalette.shared.color(type: .brandColor, themeStyle: .light))

                messageAttributedString.append(learnMoreAttributedString)

                return messageAttributedString
            }
            .unwrap()
    }

    var learnMoreTap = PublishSubject<Void>()
    var learnMoreClicked: Observable<Void> {
        return learnMoreTap
            .asObservable()
    }
}

enum OWCommentStatus {
    case rejected
    case pending
    case none
}

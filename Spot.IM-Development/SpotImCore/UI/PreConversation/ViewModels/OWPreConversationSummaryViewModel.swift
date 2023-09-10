//
//  OWPreConversationHeaderViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationSummaryViewModelingInputs {
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeCounterLabelUI: PublishSubject<UILabel> { get }
}

protocol OWPreConversationSummaryViewModelingOutputs {
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
    var commentsCount: Observable<String> { get }
    var titleFontTypography: OWFontTypography { get }
    var counterFontTypography: OWFontTypography { get }
    var showNextArrow: Bool { get }
    var isVisible: Bool { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeCounterLabelUI: Observable<UILabel> { get }
}

protocol OWPreConversationSummaryViewModeling {
    var inputs: OWPreConversationSummaryViewModelingInputs { get }
    var outputs: OWPreConversationSummaryViewModelingOutputs { get }
}

class OWPreConversationSummaryViewModel: OWPreConversationSummaryViewModeling,
                                         OWPreConversationSummaryViewModelingInputs,
                                         OWPreConversationSummaryViewModelingOutputs {
    fileprivate struct Metrics {
        static let titleFontTypography: OWFontTypography = .titleLarge
        static let titleFontTypographyCompact: OWFontTypography = .bodyContext
        static let counterFontTypography: OWFontTypography = .bodyText
        static let counterFontTypographyCompact: OWFontTypography = .footnoteText
    }

    var inputs: OWPreConversationSummaryViewModelingInputs { return self }
    var outputs: OWPreConversationSummaryViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeCounterLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeCounterLabelUI = PublishSubject<UILabel>()

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeCounterLabelUI: Observable<UILabel> {
        return _triggerCustomizeCounterLabelUI
            .unwrap()
            .asObservable()
    }

    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModel()
    }()

    var commentsCount: Observable<String> {
        guard let postId = OWManager.manager.postId else { return .empty()}

        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { realtimeData in
                guard let count = realtimeData.data?.totalCommentsCount(forPostId: postId) else { return nil }
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? count.kmFormatted : ""
            }
            .asObservable()
    }

    lazy var titleFontTypography: OWFontTypography = {
        return style == .compact ? Metrics.titleFontTypographyCompact : Metrics.titleFontTypography
    }()

    lazy var counterFontTypography: OWFontTypography = {
        return style == .compact ? Metrics.counterFontTypographyCompact : Metrics.counterFontTypography
    }()

    lazy var showNextArrow: Bool = {
        return style == .compact
    }()

    lazy var isVisible: Bool = {
        return style != .none
    }()

    fileprivate let style: OWPreConversationSummaryStyle
    fileprivate let disposeBag = DisposeBag()

    init(style: OWPreConversationSummaryStyle) {
        self.style = style
        setupObservers()
    }
}

fileprivate extension OWPreConversationSummaryViewModel {
    func setupObservers() {
        triggerCustomizeTitleLabelUI
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeCounterLabelUI
            .flatMapLatest { [weak self] label -> Observable<UILabel> in
                guard let self = self else { return .empty() }
                return self.commentsCount
                    .map { _ in return label }
            }
            .bind(to: _triggerCustomizeCounterLabelUI)
            .disposed(by: disposeBag)
    }
}

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
    var titleFontSize: CGFloat { get }
    var counterFontSize: CGFloat { get }
    var showNextArrow: Bool { get }
    var isVisible: Bool { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeCounterLabelUI: Observable<UILabel> { get }
}

protocol OWPreConversationSummaryViewModeling {
    var inputs: OWPreConversationSummaryViewModelingInputs { get }
    var outputs: OWPreConversationSummaryViewModelingOutputs { get }
}

class OWPreConversationSummaryViewModel: OWPreConversationSummaryViewModeling, OWPreConversationSummaryViewModelingInputs, OWPreConversationSummaryViewModelingOutputs {
    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 24
        static let titleFontSizeCompact: CGFloat = 15
        static let counterFontSize: CGFloat = 15
        static let counterFontSizeCompact: CGFloat = 13
    }

    var inputs: OWPreConversationSummaryViewModelingInputs { return self }
    var outputs: OWPreConversationSummaryViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeCounterLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let disposeBag = DisposeBag()

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
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(postId)") else {return nil}
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? count.kmFormatted : ""
            }
            .asObservable()
    }

    lazy var titleFontSize: CGFloat = {
        return style == .compact ? Metrics.titleFontSizeCompact : Metrics.titleFontSize
    }()

    lazy var counterFontSize: CGFloat = {
        return style == .compact ? Metrics.counterFontSizeCompact : Metrics.counterFontSize
    }()

    lazy var showNextArrow: Bool = {
        return style == .compact
    }()

    lazy var isVisible: Bool = {
        return style != .none
    }()

    fileprivate let style: OWPreConversationSummaryStyle

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
            .bind(to: _triggerCustomizeCounterLabelUI)
            .disposed(by: disposeBag)
    }
}

//
//  OWConversationSummaryViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 08/02/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWConversationSummaryViewModelingInputs {
    var triggerCustomizeCounterLabelUI: PublishSubject<UILabel> { get }
}

protocol OWConversationSummaryViewModelingOutputs {
    var customizeCounterLabelUI: Observable<UILabel> { get }
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
    var conversationSortVM: OWConversationSortViewModeling { get }
    var commentsCount: Observable<String> { get }
}

protocol OWConversationSummaryViewModeling {
    var inputs: OWConversationSummaryViewModelingInputs { get }
    var outputs: OWConversationSummaryViewModelingOutputs { get }
}

class OWConversationSummaryViewModel: OWConversationSummaryViewModeling,
                                        OWConversationSummaryViewModelingInputs,
                                        OWConversationSummaryViewModelingOutputs {

    var inputs: OWConversationSummaryViewModelingInputs { return self }
    var outputs: OWConversationSummaryViewModelingOutputs { return self }

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeCounterLabelUI = BehaviorSubject<UILabel?>(value: nil)

    var triggerCustomizeCounterLabelUI = PublishSubject<UILabel>()

    var customizeCounterLabelUI: Observable<UILabel> {
        return _triggerCustomizeCounterLabelUI
            .unwrap()
            .asObservable()
    }

    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModel()
    }()

    lazy var conversationSortVM: OWConversationSortViewModeling = {
        return OWConversationSortViewModel()
    }()

    lazy var commentsCount: Observable<String> = {
        guard let postId = OWManager.manager.postId else { return .empty() }

        let realtimeService = OWSharedServicesProvider.shared.realtimeService()
        return realtimeService.realtimeData
            .map { realtimeData -> Int? in
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(postId)") else { return nil }
                return count
            }
            .unwrap()
            .map { self.getCommentsText(for: $0) }
            .asObservable()
    }()

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
        setupObservers()
    }
}

fileprivate extension OWConversationSummaryViewModel {
    func setupObservers() {
        triggerCustomizeCounterLabelUI
            .flatMapLatest { [weak self] label -> Observable<UILabel> in
                guard let self = self else { return .empty() }
                return self.commentsCount
                    .map { _ in return label }
            }
            .bind(to: _triggerCustomizeCounterLabelUI)
            .disposed(by: disposeBag)
    }

    func getCommentsText(for count: Int) -> String {
        let commentsString: String = count > 1 ?
        OWLocalizationManager.shared.localizedString(key: "Comments") :
        OWLocalizationManager.shared.localizedString(key: "Comment")

        let RTLcommentsText: String = String(count) + " " + commentsString
        let LTRcommentsText: String = count.kmFormatted + " " + commentsString
        return OWLocalizationManager.shared.semanticAttribute == .forceLeftToRight ? LTRcommentsText : RTLcommentsText
    }
}

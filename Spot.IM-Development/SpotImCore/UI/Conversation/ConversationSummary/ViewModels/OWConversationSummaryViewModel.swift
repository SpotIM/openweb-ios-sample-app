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
    var customizeCounterLabelUI: PublishSubject<UILabel> { get }
    var customizeSortLabelUI: PublishSubject<UILabel> { get }
}

protocol OWConversationSummaryViewModelingOutputs {
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

    var customizeCounterLabelUI = PublishSubject<UILabel>()
    var customizeSortLabelUI = PublishSubject<UILabel>()

    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModel()
    }()

    lazy var conversationSortVM: OWConversationSortViewModeling = {
        return OWConversationSortViewModel()
    }()

    fileprivate let _commentsCount = BehaviorSubject<Int?>(value: nil)
    lazy var commentsCount: Observable<String> = {
        guard let postId = OWManager.manager.postId else { return .empty() }

        let realtimeService = OWSharedServicesProvider.shared.realtimeService()
        return realtimeService.realtimeData
            .map { realtimeData -> Int? in
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(postId)") else { return nil }
                return count
            }
            .unwrap()
            .map { count in
                let commentsText: String = count > 1 ?
                LocalizationManager.localizedString(key: "Comments") :
                LocalizationManager.localizedString(key: "Comment")
                return count.kmFormatted + " " + commentsText
            }
            .asObservable()
    }()

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let disposeBag = DisposeBag()

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider
    }
}

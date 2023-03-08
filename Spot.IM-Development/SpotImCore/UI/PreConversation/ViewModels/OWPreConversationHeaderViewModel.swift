//
//  OWPreConversationHeaderViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/10/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWPreConversationHeaderViewModelingInputs {
    var customizeTitleLabelUI: PublishSubject<UILabel> { get }
    var customizeCounterLabelUI: PublishSubject<UILabel> { get }
}

protocol OWPreConversationHeaderViewModelingOutputs {
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
    var commentsCount: Observable<String> { get }
    var titleFontSize: CGFloat { get }
    var counterFontSize: CGFloat { get }
    var showNextArrow: Bool { get }
}

protocol OWPreConversationHeaderViewModeling {
    var inputs: OWPreConversationHeaderViewModelingInputs { get }
    var outputs: OWPreConversationHeaderViewModelingOutputs { get }
}

class OWPreConversationHeaderViewModel: OWPreConversationHeaderViewModeling, OWPreConversationHeaderViewModelingInputs, OWPreConversationHeaderViewModelingOutputs {
    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 24
        static let titleFontSizeCompact: CGFloat = 15
        static let counterFontSize: CGFloat = 15
        static let counterFontSizeCompact: CGFloat = 13
    }

    var inputs: OWPreConversationHeaderViewModelingInputs { return self }
    var outputs: OWPreConversationHeaderViewModelingOutputs { return self }

    var customizeTitleLabelUI = PublishSubject<UILabel>()
    var customizeCounterLabelUI = PublishSubject<UILabel>()

    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModelNew()
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
        return isCompactMode ? Metrics.titleFontSizeCompact : Metrics.titleFontSize
    }()

    lazy var counterFontSize: CGFloat = {
        return isCompactMode ? Metrics.counterFontSizeCompact : Metrics.counterFontSize
    }()

    lazy var showNextArrow: Bool = {
       return isCompactMode
    }()

    fileprivate let isCompactMode: Bool

    init(isCompactMode: Bool) {
        self.isCompactMode = isCompactMode
    }
}

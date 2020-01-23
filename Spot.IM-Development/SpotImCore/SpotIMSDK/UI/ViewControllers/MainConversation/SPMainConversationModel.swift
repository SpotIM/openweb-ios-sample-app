//
//  SPMainConversationModel.swift
//  Spot.IM-Core
//
//  Created by Eugene on 7/30/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

struct RankActionDataModel {
    
    let change: SPRankChange
    let commentId: String?
    let parrentId: String?
    let conversationId: String?
    
}

typealias BooleanCompletion = (Bool, Error?) -> Void

let navigationAvatarSize: CGSize = CGSize(width: 25.0, height: 25.0)

protocol MainConversationModelDelegate: class {
    func totalTypingCountDidUpdate(count: Int)
    func stopTypingTrack()
}

protocol CommentsCounterDelegate: class {
    func commentsCountDidUpdate(count: Int)
}

final class SPMainConversationModel {
    
    /// MulticastDelegate for events that should be handled simultaneously in different places
    /// Beware of `SPMainConversationDataSource` data changings in this way
    var delegates: MulticastDelegate<MainConversationModelDelegate> = .init()
    var commentsCounterDelegates: MulticastDelegate<CommentsCounterDelegate> = .init()
    
    private let CURRENT_ADS_GROUP_TEST_NAME: String = "33"
    private let typingVisibilityAdditionalTimeInterval: Double = 5.0

    private let commentUpdater: SPCommentUpdater
    private let imageProvider: SPImageURLProvider
    private let realTimeService: RealTimeService
    
    private var realTimeTimer: Timer?
    private var realTimeData: RealTimeModel?
    private var shouldUserBeNotified: Bool = false

    private(set) var dataSource: SPMainConversationDataSource
    private(set) var sortOption: SPCommentSortMode = .best {
        didSet {
            if oldValue != sortOption {
                
                sortingUpdateHandler?(oldValue == dataSource.sortMode)
            }
        }
    }
    
    weak var commentsActionDelegate: CommentsActionDelegate?
    
    var pendingComment: SPComment? {
        didSet {
            if pendingComment != nil {
                commentsActionDelegate?.localCommentWasCreated()
            }
        }
    }
    
    var sortingUpdateHandler: ((Bool) -> Void)?
    
    init(commentUpdater: SPCommentUpdater,
         conversationDataSource: SPMainConversationDataSource,
         imageProvider: SPImageURLProvider,
         realTimeService: RealTimeService) {
        self.realTimeService = realTimeService
        self.commentUpdater = commentUpdater
        self.imageProvider = imageProvider
        dataSource = conversationDataSource
        
        dataSource.messageCounterUpdated = { [weak self] count in
            self?.commentsCounterDelegates.invoke { $0.commentsCountDidUpdate(count: count) }
        }
        
        dataSource.sortIsUpdated = { [weak self] in
            if let self = self {
                self.sortOption = self.dataSource.sortMode ?? .newest
            }
        }
    }
    
    func startTypingTracking() {
        realTimeService.startRealTimeDataFetching(conversationId: dataSource.conversationId)
    }
    
    func stopTypingTracking() {
        shouldUserBeNotified = false
        delegates.invoke { $0.stopTypingTrack() }
        realTimeService.stopRealTimeDataFetching(conversationId: dataSource.conversationId)
    }
    
    func handlePendingComment() {
        guard let comment = pendingComment else { return }
        if !comment.isReply {
            commentsActionDelegate?.localCommentWillBeCreated()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.dataSource.update(with: comment)
            self?.pendingComment = nil
        }
    }

    func handleMessageCreationBlockage(with messageText: String?) {
        commentsActionDelegate?.messageCreationBlocked(with: messageText)
    }
    
    func copyCommentText(at indexPath: IndexPath) {
        UIPasteboard.general.string = dataSource.cellData(for: indexPath).commentText
    }
    
    func areCommentsEmpty() -> Bool {
        return dataSource.messageCount == 0 ||
            dataSource.messageCount == nil
    }
    
    func changeRank(with actionModel: RankActionDataModel, completion: @escaping BooleanCompletion) {
        commentUpdater.changeRank(actionModel.change,
                                  for: actionModel.commentId,
                                  with: actionModel.parrentId,
                                  in: actionModel.conversationId,
                                  completion: completion)
    }
    
    func fetchNavigationAvatar(completion: @escaping ImageLoadingCompletion) {
        let avatarImageURL = self.dataSource.currentUserAvatarUrl
        if let key = avatarImageURL?.absoluteString,
            let image = ImageCache.sdkCache.image(for: key) {
            completion(image, nil)
        } else {
            imageProvider.image(with: avatarImageURL,
                                size: navigationAvatarSize,
                                completion: completion)
        }
    }
    
    func sortActions() -> [UIAlertAction] {
        var actions: [UIAlertAction] = SPCommentSortMode.allCases.map { [weak self] option in
            switch option {
            case .best:
                return UIAlertAction(title: option.title, style: .default) { _ in
                    SPAnalyticsHolder.default.log(event: .sortByClicked(option), source: .conversation)
                    self?.sortOption = option
                }
                
            case .newest:
                return UIAlertAction(title: option.title, style: .default) { _ in
                    SPAnalyticsHolder.default.log(event: .sortByClicked(option), source: .conversation)
                    self?.sortOption = option
                }
                
            case .oldest:
                return UIAlertAction(title: option.title, style: .default) { _ in
                    SPAnalyticsHolder.default.log(event: .sortByClicked(option), source: .conversation)
                    self?.sortOption = option
                }
            }
        }

        let cancelAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Cancel"),
            style: .cancel
        )
        actions.append(cancelAction)
        
        return actions
    }
    
    func commentAvailableActions(_ commentId: String) -> [UIAlertAction] {
        let viewModel = dataSource.commentViewModel(commentId)
        let availability = commentActionsAvailability(viewModel: viewModel)
        
        var actions: [UIAlertAction] = []

        let shareAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Share"),
            style: .default) { [weak self] _ in
                self?.commentsActionDelegate?.prepareFlowForAction(.share(commentId: commentId))
        }
        actions.append(shareAction)
        if availability.isReportable {
            let reportAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Report"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.report(commentId: commentId))
            }
            actions.append(reportAction)
        }

        if availability.isDeletable {
            let deleteAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Delete"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.delete(commentId: commentId))
            }
            actions.append(deleteAction)
        }
        
        let cancelAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Cancel"),
            style: .cancel
        )
        if !actions.isEmpty {
            actions.append(cancelAction)
        }
        
        return actions
    }
    
    func commentActionsAvailability(viewModel: CommentViewModel?) -> CommentActionAvailability {
        guard let viewModel = viewModel else { return (false, false, false) }
        
        let isDeletable = !viewModel.isDeleted && viewModel.authorId == SPUserSessionHolder.session.user?.id
        let isEditable = !viewModel.isDeleted && viewModel.authorId == SPUserSessionHolder.session.user?.id
        let isReportable = !viewModel.isDeleted && !(viewModel.authorId == SPUserSessionHolder.session.user?.id)

        return (isDeletable, isEditable, isReportable)
    }
    
    func adsGroup() -> ABGroup? {
        return dataSource.abData?
            .first(where: { $0.testName == CURRENT_ADS_GROUP_TEST_NAME })?
            .abTestGroup
    }
    
}

extension SPMainConversationModel {
    
    func deleteComment(with id: String, completion: @escaping (Error?) -> Void) {
        let commentViewModel = dataSource.commentViewModel(id)
        
        var parameters: [String: Any] = [APIKeys.messageId: id]
        if commentViewModel?.hasOffset ?? false {
            parameters[APIKeys.parentId] = commentViewModel?.parentCommentId
        }
        commentUpdater.deleteComment(
            parameters: parameters,
            postId: dataSource.conversationId,
            success: { [weak self] deletionData in
                self?.dataSource.deleteComment(with: id, isSoft: true)
                completion(nil)
            },
            failure: { error in
                completion(error)
            }
        )
    }
    
    func shareComment(with id: String, completion: @escaping (URL?, Error?) -> Void) {
        let commentViewModel = dataSource.commentViewModel(id)
        
        var parameters: [String: Any] = [APIKeys.messageId: id]
        if commentViewModel?.hasOffset ?? false {
            parameters[APIKeys.parentId] = commentViewModel?.parentCommentId
        }
        commentUpdater.shareComment(
            parameters: parameters,
            postId: dataSource.conversationId,
            success: { url in
                completion(url, nil)
            },
            failure: { error in
                completion(nil, error)
            }
        )
    }
    
    func reportComment(with id: String, completion: @escaping (Error?) -> Void) {
        let commentViewModel = dataSource.commentViewModel(id)
        
        var parameters: [String: Any] = [APIKeys.messageId: id]
        if commentViewModel?.hasOffset ?? false {
            parameters[APIKeys.parentId] = commentViewModel?.parentCommentId
        }
        commentUpdater.reportComment(
            parameters: parameters,
            postId: dataSource.conversationId,
            success: {
                self.dataSource.deleteComment(with: id, isCascade: true)
                completion(nil)
            },
            failure: { error in
                completion(error)
            }
        )
    }
    
    func editComment(with id: String) {
        //edit logic here
    }
    
    private enum APIKeys {
        static let messageId = "message_id"
        static let parentId = "parent_Id"
    }
}

extension SPMainConversationModel: RealTimeServiceDelegate {
    func realTimeDataDidUpdate(realTimeData: RealTimeModel, shouldUserBeNotified: Bool, timeOffset: Int) {
        guard let spotId = SPClientSettings.main.spotKey else { return }
        
        self.shouldUserBeNotified = shouldUserBeNotified
        self.realTimeData = realTimeData
        let fullConversationId = "\(spotId)_\(dataSource.conversationId)"
        let totalTypingCount: Int = realTimeData.data?.totalTypingCountForConversation(fullConversationId)
            ?? 0
        let totalCommentsCount: Int = self.liveTotalCommentsCount()
        self.dataSource.messageCount = totalCommentsCount
        if shouldUserBeNotified {
            delegates.invoke { $0.totalTypingCountDidUpdate(count: totalTypingCount) }
            if totalCommentsCount > 0 {
                commentsCounterDelegates.invoke { $0.commentsCountDidUpdate(count: totalCommentsCount)}
            }
            
            scheduleTypingCleaningTimer(
                timeOffset: Double(timeOffset) + typingVisibilityAdditionalTimeInterval
            )
        }
    }
    
    /// Returns current visible typing count
    func typingCount() -> Int {
        guard let spotId = SPClientSettings.main.spotKey else { return 0 }

        let fullConversationId = "\(spotId)_\(dataSource.conversationId)"
        let totalTypingCount = realTimeData?.data?.totalTypingCountForConversation(fullConversationId)
            ?? 0
        
        return shouldUserBeNotified ? totalTypingCount : 0
    }
    
    func liveTotalCommentsCount() -> Int {
        guard let spotId = SPClientSettings.main.spotKey else { return 0 }
        let fullConversationId = "\(spotId)_\(dataSource.conversationId)"
        
        let commentsCount = realTimeData?.data?.commentsCountForConversation(fullConversationId) ?? 0
        let repliesCount = realTimeData?.data?.repliesCountForConversation(fullConversationId) ?? 0
        return commentsCount + repliesCount
    }
    
    /// Will update current typings count value to `0` after `constant` seconds of server realtime  ''silence''
    private func scheduleTypingCleaningTimer(timeOffset: Double) {
        realTimeTimer?.invalidate()
        realTimeTimer = nil
        realTimeTimer = Timer.scheduledTimer(
            withTimeInterval: timeOffset,
            repeats: false
        ) { [weak self] _ in
            self?.delegates.invoke { $0.totalTypingCountDidUpdate(count: 0) }
        }
    }
}

protocol CommentsActionDelegate: class {
    
    func prepareFlowForAction(_ type: ActionType)
    func localCommentWasCreated()
    func localCommentWillBeCreated()
    func messageCreationBlocked(with messageText: String?)
}

enum ActionType {
    case delete(commentId: String)
    case report(commentId: String)
    case edit(commentId: String)
    case share(commentId: String)
}

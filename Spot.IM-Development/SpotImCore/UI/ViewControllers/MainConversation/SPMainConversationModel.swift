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

protocol MainConversationModelDelegate: AnyObject {
    func totalTypingCountDidUpdate(count: Int, newCommentsCount: Int)
    func stopTypingTrack()
}

protocol CommentsCounterDelegate: AnyObject {
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
    private let imageProvider: SPImageProvider
    private let realTimeService: RealTimeService
    
    private var realTimeTimer: Timer?
    private var realTimeData: RealTimeModel?
    private var shouldUserBeNotified: Bool = false
    private let abTestsData: AbTests
    
    // Idealy a VM for the whole VC will expose this VM for the little view from it's own outputs protocol
    // Will refactor once we will move to MVVM
    let onlineViewingUsersPreConversationVM: OWOnlineViewingUsersCounterViewModeling = OWOnlineViewingUsersCounterViewModel()
    
    // We need one for the pre conversation and one for the conversation. We should never use the same VM for two separate VCs
    // The whole idea that this model class is being used for both different VCs with the same instance is anti pattern of MVC
    let onlineViewingUsersConversationVM: OWOnlineViewingUsersCounterViewModeling = OWOnlineViewingUsersCounterViewModel()
    
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
         imageProvider: SPImageProvider,
         realTimeService: RealTimeService,
         abTestData: AbTests) {
        self.realTimeService = realTimeService
        self.commentUpdater = commentUpdater
        self.imageProvider = imageProvider
        self.abTestsData = abTestData
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
        realTimeService.startRealTimeDataFetching(conversationId: dataSource.postId)
    }
    
    func stopTypingTracking() {
        shouldUserBeNotified = false
        delegates.invoke { $0.stopTypingTrack() }
        realTimeService.stopShowingRealtimeUI(for: dataSource.postId)
    }
    
    func stopRealTimeFetching() {
        realTimeService.stopRealTimeDataFetching()
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
    
    func handleEditedComment(comment: SPComment) {
        dataSource.update(with: comment)
    }

    func handleMessageCreationBlockage(with messageText: String?) {
        commentsActionDelegate?.messageCreationBlocked(with: messageText)
    }
    
    func copyCommentText(at indexPath: IndexPath) {
        UIPasteboard.general.string = dataSource.cellData(for: indexPath).commentText
    }
    
    func areCommentsEmpty() -> Bool {
        return dataSource.messageCount == 0 && pendingComment == nil
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
            imageProvider.image(from: avatarImageURL,
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
    
    func commentAvailableActions(_ commentId: String, sender: UIButton) -> [UIAlertAction] {
        let viewModel = dataSource.commentViewModel(commentId)
        let availability = commentActionsAvailability(viewModel: viewModel)
        let replyingToID = viewModel?.rootCommentId
        var actions: [UIAlertAction] = []
        
        let shareAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Share"),
            style: .default) { [weak self] _ in
                self?.commentsActionDelegate?.prepareFlowForAction(.share(commentId: commentId, replyingToID: replyingToID), sender: sender)
            }
        actions.append(shareAction)
        if availability.isReportable {
            let reportAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Report"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.report(commentId: commentId, replyingToID: replyingToID), sender: sender)
                }
            actions.append(reportAction)
        }
        
        if availability.isEditable {
            let editAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Edit"),
                style: .default,
                handler: {[weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.edit(commentId: commentId, replyingToID: replyingToID), sender: sender)
                }
            )
            actions.append(editAction)
        }

        if availability.isDeletable {
            let deleteAction = UIAlertAction(
                title: LocalizationManager.localizedString(key: "Delete"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.delete(commentId: commentId, replyingToID: replyingToID), sender: sender)
                }
            actions.append(deleteAction)
        }
        
        let cancelAction = UIAlertAction(
            title: LocalizationManager.localizedString(key: "Cancel"),
            style: .cancel
        ) { action in
            SPAnalyticsHolder.default.log(event: .messageContextMenuClosed(messageId: commentId, relatedMessageId: replyingToID), source: .conversation)
        }
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
    
    func adsGroup() -> AdsABGroup {
        if let abGroup = abTestsData.tests
            .first(where: { $0.testName == CURRENT_ADS_GROUP_TEST_NAME })?
            .abTestGroup {
            return AdsABGroup(abGroup: abGroup, isUserRegistered: SPUserSessionHolder.session.user?.registered ?? false, disableInterstitialOnLogin: SPConfigsDataSource.appConfig?.mobileSdk.disableInterstitialOnLogin ?? false)
        }
        
        return AdsABGroup()
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
            postId: dataSource.postId,
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
            postId: dataSource.postId,
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
            postId: dataSource.postId,
            success: {
                // update model & cache on reported comment
                self.dataSource.reportComment(with: id)
                SPUserSessionHolder.reportComment(commentId: id)
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
        guard let spotId = SPClientSettings.main.spotKey, let data = realTimeData.data else { return }
        
        self.shouldUserBeNotified = shouldUserBeNotified
        self.realTimeData = realTimeData
        let fullConversationId = "\(spotId)_\(dataSource.postId)"
        
        do {
            let onlineViewingUsersModel = try data.onlineViewingUsersCount(fullConversationId)
            onlineViewingUsersPreConversationVM.inputs.configureModel(onlineViewingUsersModel)
            onlineViewingUsersConversationVM.inputs.configureModel(onlineViewingUsersModel)
            
            let totalTypingCount: Int = try data.totalTypingCountForConversation(fullConversationId)
            let totalCommentsCount: Int = try data.totalCommentsCountForConversation(fullConversationId)
            let newComments: Int = try data.totalNewCommentsForConversation(fullConversationId)
            self.dataSource.messageCount = totalCommentsCount
            if shouldUserBeNotified {
                delegates.invoke { $0.totalTypingCountDidUpdate(count: totalTypingCount, newCommentsCount: newComments) }
                if totalCommentsCount > 0 {
                    commentsCounterDelegates.invoke { $0.commentsCountDidUpdate(count: totalCommentsCount)}
                }
                
                scheduleTypingCleaningTimer(
                    timeOffset: Double(timeOffset) + typingVisibilityAdditionalTimeInterval
                )
            }
        } catch {
            if let realtimeError = error as? RealTimeError {
                Logger.error("Failed to update real time data: \(realtimeError)")
                stopRealTimeFetching()
                SPDefaultFailureReporter.shared.report(error: .realTimeError(realtimeError))
            }
        }
    }
    
    /// Returns current visible typing count
    func typingCount() throws -> Int {
        guard let spotId = SPClientSettings.main.spotKey, let data = self.realTimeData?.data else { return 0 }
        
        let fullConversationId = "\(spotId)_\(dataSource.postId)"
        let totalTypingCount = try data.totalTypingCountForConversation(fullConversationId)
        
        return shouldUserBeNotified ? totalTypingCount : 0
    }
    
    /// Returns current visible new messages count
    func newMessagesCount() throws -> Int {
        guard let spotId = SPClientSettings.main.spotKey, let data = self.realTimeData?.data else { return 0 }
        
        let fullConversationId = "\(spotId)_\(dataSource.postId)"
        let totalNewCommentsCount = try data.totalNewCommentsForConversation(fullConversationId)
        
        return shouldUserBeNotified ? totalNewCommentsCount : 0
    }
    
    /// Will update current typings count value to `0` after `constant` seconds of server realtime  ''silence''
    private func scheduleTypingCleaningTimer(timeOffset: Double) {
        realTimeTimer?.invalidate()
        realTimeTimer = nil
        realTimeTimer = Timer.scheduledTimer(
            withTimeInterval: timeOffset,
            repeats: false
        ) { [weak self] _ in
            self?.delegates.invoke { $0.totalTypingCountDidUpdate(count: 0, newCommentsCount: 0) }
        }
    }
}

protocol CommentsActionDelegate: AnyObject {
    
    func prepareFlowForAction(_ type: ActionType, sender: UIButton)
    func localCommentWasCreated()
    func localCommentWillBeCreated()
    func messageCreationBlocked(with messageText: String?)
}

enum ActionType {
    case delete(commentId: String, replyingToID: String?)
    case report(commentId: String, replyingToID: String?)
    case edit(commentId: String, replyingToID: String?)
    case share(commentId: String, replyingToID: String?)
}

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

final class SPMainConversationModel {
    
    private let commentUpdater: SPCommentUpdater
    private let imageProvider: SPImageURLProvider
    
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
         imageProvider: SPImageURLProvider) {
        self.commentUpdater = commentUpdater
        self.imageProvider = imageProvider
        dataSource = conversationDataSource
        dataSource.sortIsUpdated = { [weak self] in
            self?.sortOption = self?.dataSource.sortMode ?? .newest
        }
    }
    
    func handlePendingComment() {
        guard let comment = pendingComment else { return }
        
        commentsActionDelegate?.localCommentWillBeCreated()
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
        let avatarImageURL = SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize)
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
                    self?.sortOption = option
                }
                
            case .newest:
                return UIAlertAction(title: option.title, style: .default) { _ in
                    self?.sortOption = option
                }
                
            case .oldest:
                return UIAlertAction(title: option.title, style: .default) { _ in
                    self?.sortOption = option
                }
            }
        }

        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "cancel title"),
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
            title: NSLocalizedString("Share", comment: "share title"),
            style: .default) { [weak self] _ in
                self?.commentsActionDelegate?.prepareFlowForAction(.share(commentId: commentId))
        }
        actions.append(shareAction)
        if availability.isReportable {
            let reportAction = UIAlertAction(
                title: NSLocalizedString("Report", comment: "report title"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.report(commentId: commentId))
            }
            actions.append(reportAction)
        }

        if availability.isDeletable {
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("Delete", comment: "delete title"),
                style: .default) { [weak self] _ in
                    self?.commentsActionDelegate?.prepareFlowForAction(.delete(commentId: commentId))
            }
            actions.append(deleteAction)
        }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "cancel title"),
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
}

extension SPMainConversationModel {
    
    func deleteComment(with id: String, completion: @escaping (Error?) -> Void) {
        SPAnalyticsHolder.default.log(event: .deleteMessage, source: .conversation)
        
        let commentViewModel = dataSource.commentViewModel(id)
        
        var parameters: [String: Any] = [APIKeys.messageId: id]
        if commentViewModel?.hasOffset ?? false {
            parameters[APIKeys.parentId] = commentViewModel?.parentCommentId
        }
        commentUpdater.deleteComment(
            parameters: parameters,
            postId: dataSource.conversationId,
            success: { [weak self] deletionData in
                self?.dataSource.deleteComment(with: id, isSoft: deletionData.softDeleted ?? false)
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

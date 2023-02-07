//
//  SPMainConversationDataSource.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 14/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//
// swiftlint:disable file_length

import Foundation

internal protocol SPMainConversationDataSourceDelegate: NSObjectProtocol {
    
    func reload(shouldBeScrolledToTop: Bool)
    func reload(scrollToIndexPath: IndexPath?)
    func reloadAt(indexPath: IndexPath)
    func dataSource(dataSource: SPMainConversationDataSource, didInsertRowsAt indexPaths: [IndexPath])
    func dataSource(dataSource: SPMainConversationDataSource, didInsertSectionsAt indexex: [Int])
    func dataSource(didChangeRowAt indexPaths: IndexPath)
    func dataSource(dataSource: SPMainConversationDataSource, didCollapseRowsAt indexPaths: [IndexPath])
    func dataSource(dataSource: SPMainConversationDataSource, didRemoveSection seciton: Int)
    
}

typealias CommentActionAvailability = (isDeletable: Bool, isEditable: Bool, isReportable: Bool, isMuteable: Bool, isShareable: Bool)
typealias DeletedIndexPathsInfo = (indexPathes: [IndexPath], shouldRemoveSection: Bool)

internal final class SPMainConversationDataSource {
    
    weak var delegate: SPMainConversationDataSourceDelegate?
    unowned var conversationModel: SPMainConversationModel?

    let articleMetadata: SpotImArticleMetadata
    var sortIsUpdated: (() -> Void)?
    var messageCounterUpdated: ((Int) -> Void)?
    var messageCount: Int = 0
    var minVisibleReplies: Int = 2
    var communityQuestion: String?
    var isReadOnly: Bool = false

    private(set) var sortMode: SPCommentSortMode?
    private(set) var postId: String
    private(set) var currentUser: SPUser? = SPUserSessionHolder.session.user {
        didSet {
            SPAnalyticsHolder.default.userId = currentUser?.id
            SPAnalyticsHolder.default.isUserRegistered = currentUser?.registered ?? false
        }
    }
    
    private let dataProvider: SPConversationsDataProvider
    
    private var repliesProviders = [String: SPConversationsDataProvider]()
    private var cellData = [[CommentViewModel]]()
    private var hiddenData = [String: [CommentViewModel]]()
    private var users = [String: SPUser]()
    private var extractData: SPConversationExtraDataRM?
    private var cachedCommentReply: CommentViewModel?
    private var selectedLabelIds: [String]?
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    internal var showReplies: Bool = false {
        didSet {
            expandAllCommentsIfNeeded()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        SPAnalyticsHolder.default.postId = nil
    }

    init(with postId: String, articleMetadata: SpotImArticleMetadata, dataProvider: SPConversationsDataProvider,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        SPAnalyticsHolder.default.postId = postId
        
        self.postId = postId
        self.dataProvider = dataProvider
        self.articleMetadata = articleMetadata
        self.servicesProvider = servicesProvider
        
        dataProvider.conversationAsync(postId: postId, articleUrl: articleMetadata.url)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateDisplayName),
            name: .userDisplayNameFrozen,
            object: nil
        )
        
    }
    
    // MARK: - Internal methods and computed properties
    
    internal var isLoading: Bool {
        return dataProvider.isLoading
    }
    
    public var shouldShowBanner = false {
        willSet {
            if newValue {
                cellData.insert([], at: 0)
            } else {
                cellData.remove(at: 0)
            }
            
        }
    }
    
    internal var canLoadNextPage: Bool {
        return dataProvider.canLoadNextPage
    }
    
    internal var currentUserAvatarUrl: URL? {
        return SPUserSessionHolder.session.user?.imageURL(size: navigationAvatarSize)
    }
    
    internal var currentUserName: String {
        return currentUser?.displayName ?? currentUser?.userName ?? ""
    }
    
    internal var hasNext: Bool {
        return dataProvider.hasNext
    }
    
    private var totalCellCount: Int {
        let count = cellData.reduce(0, { (result, section) in
            result + section.count
        })
        return count
    }
    
    internal func imageURL(with id: String?) -> URL? {
        return dataProvider.imageURLProvider?.imageURL(with: id, size: nil)
    }
    
    internal func conversation(_ mode: SPCommentSortMode,
                               page: SPPaginationPage,
                               loadingStarted: (() -> Void)? = nil,
                               loadingFinished: (() -> Void)? = nil,
                               completion: @escaping (Bool, SPNetworkError?) -> Void) {
        sortMode = mode
        sortIsUpdated?()
        dataProvider.conversation(
            postId,
            mode,
            page: page,
            loadingStarted: loadingStarted,
            loadingFinished: loadingFinished
        ) { [weak self] (response, error) in
            guard let self = self
                else {
                    completion(false, SPNetworkError.default)
                    return
            }
            
            if let error = error {
                completion(false, error)
            } else {
                // Update user ssoPublisherId
                if let userSsoPublisherId = response?.user?.ssoPublisherId {
                    SPUserSessionHolder.updateSessionUserSSOPublisherId(userSsoPublisherId)
                }
                
                if let newUsers = response?.conversation?.users {
                    let mergedUsers = self.users.merging(newUsers) { $1 }
                    self.users = mergedUsers
                }
                if let extractData = response?.extractData {
                    self.extractData = extractData
                }

                self.messageCount = response?.conversation?.messagesCount ?? 0
                self.messageCounterUpdated?(self.messageCount)
                
                self.cellData = self.processed(response?.conversation?.comments)
                if self.shouldShowBanner {
                    self.cellData.insert([], at: 0)
                }
                
                self.communityQuestion = response?.conversation?.communityQuestion ?? nil
                self.isReadOnly = response?.conversation?.readOnly ?? false
                completion(true, nil)
            }
        }
    }
    
    internal func comments(
        _ mode: SPCommentSortMode,
        page: SPPaginationPage,
        loadingStarted: (() -> Void)? = nil,
        loadingFinished: (() -> Void)? = nil,
        completion: @escaping (Bool, IndexSet?, Error?) -> Void) {
        sortMode = mode
        sortIsUpdated?()
        dataProvider.conversation(
            postId,
            mode,
            page: page,
            loadingStarted: loadingStarted,
            loadingFinished: loadingFinished
        ) { [weak self] (response, error) in
            guard
                let self = self
                else {
                    completion(false, nil, SPNetworkError.default)
                    return
            }
            
            if let error = error {
                completion(false, nil, error)
            } else {
                if let newUsers = response?.conversation?.users {
                    let mergedUsers = self.users.merging(newUsers) { $1 }
                    self.users = mergedUsers
                }

                let processedComments = self.processed(response?.conversation?.comments)

                let insertedSections = self.insertedSections(with: processedComments.count)
                self.cellData.append(contentsOf: processedComments)

                self.messageCount = response?.conversation?.messagesCount ?? 0
                self.messageCounterUpdated?(self.messageCount)

                completion(true, insertedSections, nil)
            }
        }
    }

    internal func expandAllCommentsIfNeeded() {
        guard showReplies else { return }
        
        for key in hiddenData.keys {
            if let path = indexPathOfComment(with: key), let replies = hiddenData[key] {
                cellData[path.section].insert(contentsOf: replies, at: path.row + 1)
            }
        }
        hiddenData.removeAll()
    }

    internal func showMoreReplies(
        for commentId: String?,
        sortMode: SPCommentSortMode,
        loadingStarted: (() -> Void)? = nil,
        loadingFinished: (() -> Void)? = nil) {
        
        guard let commentId = commentId, let indexPath = indexPathOfComment(with: commentId) else { return }
        
        let provider = repliesProviders[commentId]
        
        if let comments = hiddenData[commentId] {
            
            let indexPaths = IndexPath.indexPaths(forSection: indexPath.section,
                                                  from: indexPath.row + 1,
                                                  pathesCount: comments.count)
            cellData[indexPath.section].insert(contentsOf: comments, at: indexPath.row + 1)
            
            hiddenData[commentId] = nil
            
            delegate?.dataSource(dataSource: self, didInsertRowsAt: indexPaths)
            updateReplyButton(with: provider, inCellWith: indexPath)
            
            return
        }
        
        // to show loader
        DispatchQueue.main.async { self.updateReplyButton(with: provider, inCellWith: indexPath) }
        
        provider?.comments(
            postId,
            sortMode,
            page: .next,
            parentId: commentId,
            loadingStarted: loadingStarted,
            loadingFinished: loadingFinished) { (response, _) in
                if let newUsers = response?.conversation?.users {
                    let mergedUsers = self.users.merging(newUsers) { $1 }
                    self.users = mergedUsers
                }
                
                let parentCellData = self.comment(with: commentId)
                
                let processedReplies = self.processedReplies(
                    response?.conversation?.comments,
                    replyingToCommentId: parentCellData?.commentId,
                    replyingToDisplayName: (parentCellData?.isDeleted == true) ? nil : parentCellData?.displayName
                )
                if let indexPath = self.indexPathOfComment(with: commentId) {
                    self.cellData[indexPath.section].insert(contentsOf: processedReplies,
                                                            at: indexPath.row + 1)
                    
                    self.updateReplyButton(with: provider, inCellWith: indexPath)
                    let indexPaths = IndexPath.indexPaths(forSection: indexPath.section,
                                                          from: indexPath.row + 1,
                                                          pathesCount: processedReplies.count)
                    self.delegate?.dataSource(dataSource: self, didInsertRowsAt: indexPaths)
                }
        }
    }

    private func resetAllComments() {
        cellData.removeAll()
        hiddenData.removeAll()
        repliesProviders.removeAll()
    }
    
    internal func isTimeToLoadNextPage(forRowAt indexPath: IndexPath) -> Bool {
        return absoluteIndex(ofRowAt: indexPath) >= totalCellCount - 5
    }

    func numberOfSections() -> Int {
        let count = cellData.filter { !$0.isEmpty }.count + (isLoading ? 1 : 0) + (shouldShowBanner ? 1 : 0)
        return count
    }
    
    internal func commentViewModel(_ id: String) -> CommentViewModel? {
        let comment = cellData.flatMap { $0 }.first { $0.commentId == id }
        
        return comment
    }
    
    internal func commentCreationModel() -> SPCommentCreationDTO {
        return createSPCommentDTO()
    }
    
    internal func replyCreationModel(for id: String) -> SPCommentCreationDTO {
        let comment = cellData.flatMap { $0 }.first { $0.commentId == id }
        
        let replyModel = SPReplyCommentDTO(
            authorName: comment?.displayName,
            commentText: comment?.commentText,
            commentId: id,
            rootCommentId: comment?.rootCommentId,
            parentDepth: comment?.depth
        )
        
        return createSPCommentDTO(replyModel: replyModel)
    }
    
    internal func editCommentModel(for id: String) -> SPCommentCreationDTO {
        let comment = cellData.flatMap { $0 }.first { $0.commentId == id }
        var replyModel : SPReplyCommentDTO?
        var editModel: SPEditCommentDTO?
        
        if let userComment = comment {
            if userComment.isAReply(),
               let replyComment = cellData.flatMap { $0 }.first { $0.commentId == userComment.parentCommentId } {
                replyModel = SPReplyCommentDTO(
                    authorName: replyComment.displayName,
                    commentText: replyComment.commentText,
                    commentId: replyComment.commentId ?? "",
                    rootCommentId: replyComment.rootCommentId,
                    parentDepth: replyComment.depth
                )
            }
            
            editModel = gatherEditModelData(comment: userComment)
            return createSPCommentDTO(replyModel: replyModel, editModel: editModel)
        }
        
        return createSPCommentDTO()
        
    }
    
    internal func createSPCommentDTO(replyModel: SPReplyCommentDTO? = nil, editModel: SPEditCommentDTO? = nil) -> SPCommentCreationDTO {
        
        return SPCommentCreationDTO(
            articleMetadata: articleMetadata,
            currentUserAvatarUrl: currentUserAvatarUrl,
            postId: postId,
            displayName: currentUserName,
            user: currentUser,
            replyModel: replyModel,
            editModel: editModel
        )
    }
    
    private func gatherEditModelData(comment: CommentViewModel) -> SPEditCommentDTO? {
        
        guard let commentId = comment.commentId else { return nil }
        

        return SPEditCommentDTO(commentId: commentId,
                                commentText: comment.commentText,
                                commentImage: comment.commentImage,
                                commentLabelIds: self.selectedLabelIds,
                                commentGifUrl: comment.commentGifUrl)
    }
    
    internal func numberOfRows(in section: Int) -> Int {
        if isLoading && section == numberOfSections() - 1 { // loader cell in dedicated section
            return 1
        } else if shouldShowBanner && section == 0 {
            return 1
        } else {
            return cellData[section].count
        }
    }

    internal func cellData(for indexPath: IndexPath) -> CommentViewModel {
        return cellData[indexPath.section][indexPath.row]
    }

    /// Free from replies and deleted comments
    internal func clippedCellData(for indexPath: IndexPath) -> CommentViewModel? {
        var clippedCellData = [[CommentViewModel]]()
        for section in cellData {
            let filteredSection = section.filter {
                var isRoot = false
                if let commentId = $0.commentId, let rootCommentId = $0.rootCommentId, commentId == rootCommentId {
                    isRoot = true
                }
                return isRoot
            }
            if !filteredSection.isEmpty {
                clippedCellData.append(filteredSection)
            }
        }
        guard indexPath.section < clippedCellData.count, indexPath.row < clippedCellData[indexPath.section].count else {
            return nil
        }
        
        clippedCellData[indexPath.section][indexPath.row].isCollapsed = true
        
        return clippedCellData[indexPath.section][indexPath.row]
    }

    private func loadedChildren(of commentId: String?) -> [CommentViewModel]? {
        guard let commentId = commentId, let indexPath = indexPathOfComment(with: commentId) else { return nil }
        let children = cellData[indexPath.section].filter { $0.parentCommentId == commentId }

        return children
    }

    internal func updateRank(with rankChange: SPRankChange, inCellWith id: String?) {
        guard let indexPath = indexPathOfComment(with: id) else { return }

        cellData[indexPath.section][indexPath.row].rankedByUser = rankChange.to.rawValue

        var rankUp = cellData[indexPath.section][indexPath.row].rankUp
        var rankDown = cellData[indexPath.section][indexPath.row].rankDown

        switch (rankChange.from, rankChange.to) {
        case (.unrank, .up):
            rankUp += 1
        case (.unrank, .down):
            rankDown += 1
        case (.up, .unrank):
            rankUp -= 1
        case (.up, .down):
            rankUp -= 1
            rankDown += 1
        case (.down, .unrank):
            rankDown -= 1
        case (.down, .up):
            rankUp += 1
            rankDown -= 1
        default: break
        }
        cellData[indexPath.section][indexPath.row].rankUp = rankUp
        cellData[indexPath.section][indexPath.row].rankDown = rankDown

        delegate?.dataSource(didChangeRowAt: indexPath)
    }

    internal func expandCommentText(for indexPath: IndexPath) {
        cellData[indexPath.section][indexPath.row].commentTextCollapsed = false
    }

    internal func collapseCommentText(for indexPath: IndexPath) {
        cellData[indexPath.section][indexPath.row].commentTextCollapsed = true
    }

    internal func hideReplies(for commentId: String?) {
        guard let commentId = commentId else { return }
        guard let indexPath = self.indexPathOfComment(with: commentId) else { return }

        var section = cellData[indexPath.section]
        let index = indexPath.row

        // collapsing each "thread" separately
        // when the commentId is expanded again, child commets will be collapsed as they were initially
        var commentsToHide = [CommentViewModel]()

        var lastCommentToHide = section.count
        if section[index].parentCommentId?.isEmpty ?? false {
            lastCommentToHide -= minVisibleReplies
        }

        for index in index + 1 ..< lastCommentToHide {
            var data = section[index]
            if data.replyingToCommentId == commentId
                || commentsToHide.contains(where: { $0.commentId == data.replyingToCommentId }) {
                if let id = data.replyingToCommentId {
                    switch data.repliesButtonState {
                    case .expanded, .loading:
                        data.repliesButtonState = .collapsed
                    default:
                        break
                    }
                    commentsToHide.append(data)
                    if hiddenData[id] == nil {
                        hiddenData[id] = [CommentViewModel]()
                    }
                    hiddenData[id]?.append(data)
                }
            } else { break }
        }

        let lowerBound = index + 1
        let upperBound = index + commentsToHide.count
        if lowerBound <= upperBound, upperBound < section.count {
            section.removeSubrange(lowerBound ... upperBound)
            cellData[indexPath.section] = section
            resetReplyButton(inCellWith: indexPath)
            let indexPaths = IndexPath.indexPaths(forSection: indexPath.section,
                                                  from: index + 1,
                                                  pathesCount: commentsToHide.count)
            delegate?.dataSource(dataSource: self, didCollapseRowsAt: indexPaths)
        }
    }

    // MARK: - Private methods

    private func getCommentViewModel(with comment: SPComment,
                                  replyingToCommentId: String? = nil,
                                  replyingToDisplayName: String? = nil) -> CommentViewModel {
        var user: SPUser?
        if let userId = comment.userId {
            user = users[userId]
            if user == nil, let commentUsers = comment.users {
                user = commentUsers[userId]
            }
        }
        var commentViewModel = CommentViewModel(
            with: comment,
            replyingToCommentId: replyingToCommentId,
            replyingToDisplayName: replyingToDisplayName,
            color: .brandColor,
            user: user,
            imageProvider: dataProvider.imageURLProvider
        )
        
        commentViewModel.conversationModel = conversationModel
        
        return commentViewModel
    }

    private func replyViewModel(from reply: SPComment, with parent: SPComment) -> CommentViewModel {
        var displayName: String?
        if let userId = parent.userId, let user = users[userId] {
            displayName = user.displayName
        }

        let viewModel = getCommentViewModel(with: reply,
                                         replyingToCommentId: reply.parentId,
                                         replyingToDisplayName: parent.deleted ? nil :  displayName)
        makeRepliesProviderIfNeeded(for: reply, viewModel: viewModel)
        
        return viewModel
    }

    private func makeRepliesProviderIfNeeded(for comment: SPComment, viewModel: CommentViewModel) {
        if comment.hasNext || viewModel.anyHiddenReply, let replyId = comment.id, repliesProviders[replyId] == nil {
            let newProvider = dataProvider.copy(modifyingOffset: comment.offset, hasNext: comment.hasNext)
            repliesProviders[replyId] = newProvider
        }
    }

    private func processedReplies(_ comments: [SPComment]?,
                                  replyingToCommentId: String? = nil,
                                  replyingToDisplayName: String? = nil) -> [CommentViewModel] {
        var visibleComments = [CommentViewModel]()

        comments?.forEach { comment in
            var viewModel = getCommentViewModel(with: comment,
                                             replyingToCommentId: replyingToCommentId,
                                             replyingToDisplayName: replyingToDisplayName)

            makeRepliesProviderIfNeeded(for: comment, viewModel: viewModel)
            
            guard let id = comment.id, let replies = comment.replies, !replies.isEmpty else {
                visibleComments.append(viewModel)
                return
            }
            if hiddenData[id] == nil {
                hiddenData[id] = [CommentViewModel]()
            }

            replies.forEach { reply in
                hiddenData[id]?.append(replyViewModel(from: reply, with: comment))
                viewModel.repliesButtonState = .collapsed
            }

            visibleComments.append(viewModel)
        }

        if replyingToCommentId != nil {
            visibleComments.reverse()
        }

        return visibleComments
    }

    private func processed(_ comments: [SPComment]?,
                           replyingToCommentId: String? = nil,
                           replyingToDisplayName: String? = nil) -> [[CommentViewModel]] {
        var visibleComments = [[CommentViewModel]]()

        comments?.forEach { comment in
            var section = [CommentViewModel]()
            let viewModel = getCommentViewModel(with: comment,
                                             replyingToCommentId: replyingToCommentId,
                                             replyingToDisplayName: replyingToDisplayName)

            if viewModel.isCommentAuthorMuted && (comment.replies == nil || comment.replies?.isEmpty == true) {
                // if comment is muted without replies - we filter out this comment
                return
            }
            
            section.append(viewModel)

            guard let replies = comment.replies, !replies.isEmpty else {
                visibleComments.append(section)
                return
            }

            minVisibleReplies = replies.count > minVisibleReplies ? replies.count : minVisibleReplies

            replies.forEach { reply in
                let reply = replyViewModel(from: reply, with: comment)
                if showReplies {
                    section.insert(reply, at: 1)
                    if let replyId = reply.commentId,
                       let provider = repliesProviders[replyId] {
                        // The replies of the reply are hidden,
                        // we reset the offset of this reply repliesProviders
                        provider.resetOffset()
                    }
                } else if let id = comment.id {
                    if hiddenData[id] == nil {
                        hiddenData[id] = [CommentViewModel]()
                    }
                    hiddenData[id]?.append(reply)
                }
            }
            if let id = comment.id {
                hiddenData[id]?.reverse()
            }
            visibleComments.append(section)

            makeRepliesProviderIfNeeded(for: comment, viewModel: viewModel)
        }
        
        return visibleComments
    }

    private func comment(with id: String?) -> CommentViewModel? {
        for section in cellData {
            if let data = section.first(where: { $0.commentId == id }) {
                return data
            }
        }
        return nil
    }

    func indexPathOfComment(with id: String?) -> IndexPath? {
        for (sectionIndex, section) in cellData.enumerated() {
            if let index = section.firstIndex(where: { $0.commentId == id }) {
                return IndexPath(row: index, section: sectionIndex)
            }
        }
        return nil
    }
    
    func indexPathsOfComments(for userId: String) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for sectionIndex in 0..<cellData.count {
            let sectionData = cellData[sectionIndex]
            for rawIndex in 0..<sectionData.count {
                let commentVM = sectionData[rawIndex]
                if commentVM.authorId == userId {
                    let indexPath = IndexPath(row: rawIndex, section: sectionIndex)
                    indexPaths.append(indexPath)
                }
            }
        }
        return indexPaths
    }

    // the index of row if the structure was flat
    // so if there are two sections with two rows each, the row [1, 1] absolute index is 3
    private func absoluteIndex(ofRowAt indexPath: IndexPath) -> Int {
        var absoluteIndex = 0
        for (sectionIndex, section) in cellData.enumerated() {
            if sectionIndex < indexPath.section {
                absoluteIndex += section.count
            } else {
                absoluteIndex += indexPath.row
                return absoluteIndex
            }
        }
        return absoluteIndex
    }

    private func insertedSections(with insertedCount: Int) -> IndexSet {
        guard insertedCount > 0 else { return IndexSet() }
        let lowerBound = cellData.count
        let upperBound = self.cellData.count + insertedCount - 1
        var set = IndexSet(lowerBound ..< upperBound)
        if set.isEmpty {
            set = IndexSet(integer: self.cellData.count)
        }
        return set
    }

    private func updateReplyButton(with provider: SPConversationsDataProvider? = nil, inCellWith indexPath: IndexPath) {
        if provider?.isLoading ?? false {
            cellData[indexPath.section][indexPath.row].repliesButtonState = .loading
        } else if provider?.hasNext ?? false {
            cellData[indexPath.section][indexPath.row].repliesButtonState = .collapsed
        } else {
            cellData[indexPath.section][indexPath.row].repliesButtonState = .expanded
        }

        delegate?.dataSource(didChangeRowAt: indexPath)
    }

    private func resetReplyButton(inCellWith indexPath: IndexPath) {
        cellData[indexPath.section][indexPath.row].repliesButtonState = .collapsed
        delegate?.dataSource(didChangeRowAt: indexPath)
    }

    @objc
    public func updateDisplayName(notification: Notification) {
        guard let user = notification.userInfo?["user"] as? SPUser else { return }
        guard let id = user.id else { return }
        users[id]?.displayName = user.displayName
    }
    
}

extension SPMainConversationDataSource {

    /// - Parameters:
    ///     - id: id of comment to delete
    ///     - isSoft: if true, comment is only marked as deleted; default is false
    ///     - isCascade: if true, also deletes entire comment branch
    func deleteComment(with id: String, isSoft: Bool = false, isCascade: Bool = false) {
        guard let indexPath = indexPathOfComment(with: id) else { return }
        
        self.messageCount = messageCount - 1
        self.messageCounterUpdated?(self.messageCount)
        
        handleDeletedCommentReplies(commentId: id, sectionIndexPath: indexPath)
        if isSoft {
            (cellData[indexPath.section])[indexPath.row].setIsDeleted(true)
            delegate?.reload(shouldBeScrolledToTop: false)
        } else {
            let removeSection = (indexPath.row == 0 && isCascade) || cellData[indexPath.section].count == 1
            let indexPathsData = deleteComments(for: id, at: indexPath, isCascade: isCascade)
            if removeSection { // removed first comment and its whole seciton
                delegate?.dataSource(dataSource: self, didRemoveSection: indexPath.section)
            } else {
                if !indexPathsData.shouldRemoveSection {
                    delegate?.dataSource(dataSource: self, didCollapseRowsAt: indexPathsData.indexPathes)
                } else {
                    delegate?.dataSource(dataSource: self, didRemoveSection: indexPath.section)
                }
            }
        }
    }
    
    func update(with comment: SPComment) {
        servicesProvider.logger().log(level: .verbose, "update: preparing comment view model")
        let parentComment = self.comment(with: comment.parentId)

        let displayName = parentComment?.displayName
        
        let user = SPUserSessionHolder.session.user
        let viewModel = CommentViewModel(
            with: comment,
            replyingToCommentId: comment.parentId,
            replyingToDisplayName: displayName,
            color: .brandColor,
            user: user,
            imageProvider: dataProvider.imageURLProvider,
            conversationModel: conversationModel
        )
        
        cachedCommentReply = viewModel
        selectedLabelIds = comment.additionalData?.labels?.ids
        
        if comment.isReply && !comment.edited {
            pushLocalReply(reply: comment, viewModel: viewModel)
            updateRepliesButtonIfNeeded(in: parentComment)
        } else if comment.edited {
            updateEditedCommentAndSendEvent(comment: comment, viewModel: viewModel)
        } else {
            pushLocalComment(comment: comment, viewModel: viewModel)
        }
    }
    
    func reportComment(with id: String) {
        guard let indexPath = indexPathOfComment(with: id) else { return }
        (cellData[indexPath.section])[indexPath.row].isReported = true
        delegate?.reloadAt(indexPath: indexPath)
    }
    
    func isCommentInConversation(commentId: String) -> Bool {
        for section in cellData {
            for comment in section {
                if comment.commentId == commentId {
                    return true
                }
            }
        }
        return false
    }
    
    func addNewComments(comments: [SPComment]) {
        var sortedComments = comments
        sortedComments.sort {
            if let date1 = $0.writtenAt, let date2 = $1.writtenAt {
                return Date(timeIntervalSince1970: date1).timeAgo() > Date(timeIntervalSince1970: date2).timeAgo()
            } else {
                return true
            }
        }
        let processedComments = self.processed(sortedComments)
        self.cellData.insert(contentsOf: processedComments, at: self.shouldShowBanner ? 1 : 0)
    }

    func muteComment(userId: String) {
        let indexPaths = indexPathsOfComments(for: userId)
        guard !indexPaths.isEmpty else { return }

        for indexPath in indexPaths {
            var commentVM = cellData[indexPath.section][indexPath.row]
            commentVM.setIsMuted(true)
            cellData[indexPath.section][indexPath.row] = commentVM
        }

        let sectionIndexPaths = Set(indexPaths.map { $0.section }).reversed()
        sectionIndexPaths.forEach { sectionIndex in
            if isAllCommentAndRepliesShouldBeMuted(sectionIndex) {
                cellData.remove(at: sectionIndex)
            }
        }

        delegate?.reload(shouldBeScrolledToTop: false)
    }
}

fileprivate extension SPMainConversationDataSource {

    func handleDeletedCommentReplies(commentId: String, sectionIndexPath: IndexPath) {
        for i in sectionIndexPath.row + 1..<cellData[sectionIndexPath.section].count
            where cellData[sectionIndexPath.section][i].parentCommentId == commentId {
                cellData[sectionIndexPath.section][i].replyingToDisplayName = nil
        }
    }

    func handleDeletedParentComment(parentId: String) {
        guard let indexPath = indexPathOfComment(with: parentId),
            cellData[indexPath.section].filter({ $0.parentCommentId == parentId && !$0.shouldBeRemoved }).isEmpty,
            cellData[indexPath.section][indexPath.row].isDeleted else { return }

            cellData[indexPath.section][indexPath.row].shouldBeRemoved = true
            if let parentCommentId = cellData[indexPath.section][indexPath.row].parentCommentId {
                handleDeletedParentComment(parentId: parentCommentId)
            }
    }

    func deleteComments(for id: String, at indexPath: IndexPath, isCascade: Bool) -> DeletedIndexPathsInfo {
        cellData[indexPath.section][indexPath.row].shouldBeRemoved = true
        if let parentCommentId = cellData[indexPath.section][indexPath.row].parentCommentId, !parentCommentId.isEmpty {
            handleDeletedParentComment(parentId: parentCommentId)
        }
        if isCascade {
            markChildrenDeleted(for: id)
        }

        var deletedPaths = [IndexPath]()
        for (i, comment) in cellData[indexPath.section].enumerated() where comment.shouldBeRemoved {
                deletedPaths.append(IndexPath(row: i, section: indexPath.section))
        }
        cellData[indexPath.section].removeAll { $0.shouldBeRemoved }

        let shouldRemoveSection: Bool = !cellData.filter { $0.isEmpty }.isEmpty
        cellData.removeAll { $0.isEmpty }

        return (deletedPaths, shouldRemoveSection)
    }

    func markChildrenDeleted(for id: String?) {
        guard let id = id, let indexPath = indexPathOfComment(with: id) else { return }
        for i in indexPath.row..<cellData[indexPath.section].count
            where cellData[indexPath.section][i].parentCommentId == id {
            cellData[indexPath.section][i].shouldBeRemoved = true
            markChildrenDeleted(for: cellData[indexPath.section][i].commentId)
        }
    }

    func updateRepliesButtonIfNeeded(in comment: CommentViewModel?) {
        guard let isRoot = comment?.isRoot,
            let replyCount = loadedChildren(of: comment?.commentId)?.count,
            comment?.repliesButtonState == .hidden else { return }

        let minRepliesToShowButton = (isRoot ? minVisibleReplies : 0) + 1

        if replyCount == minRepliesToShowButton, let indexPath = indexPathOfComment(with: comment?.commentId) {
            cellData[indexPath.section][indexPath.row].repliesButtonState = .expanded
        }
    }

    func pushLocalComment(comment: SPComment, viewModel: CommentViewModel) {
        let logger = servicesProvider.logger()
        logger.log(level: .verbose, "pushLocalComment called, sorting is \(String(describing: sortMode))")
        let updatedMessageCount = messageCount + 1
        let dataModel = self.cellData.flatMap { $0 }.first { $0.commentId == viewModel.commentId }
        if dataModel == nil {
            logger.log(level: .verbose, "pushLocalComment: Data model not found, adding comment manually")
            let section = self.shouldShowBanner ? 1 : 0
            self.cellData.insert([viewModel], at: section)
            self.delegate?.dataSource(dataSource: self, didInsertSectionsAt: [section])
            logger.log(level: .verbose, "pushLocalComment: Updated message count: \(updatedMessageCount)")
            self.messageCount = updatedMessageCount
            self.messageCounterUpdated?(updatedMessageCount)
        }
        self.cachedCommentReply = nil
    }

    func pushLocalReply(reply: SPComment, viewModel: CommentViewModel) {
        let lastReplyViewModel = cellData.flatMap { $0 }.last { $0.parentCommentId == reply.parentId }
        let commentIndexPath = cellData
            .flatMap { $0 }
            .last { $0.commentId == reply.parentId }
            .map { indexPathOfComment(with: $0.commentId) }

        if let unwrappedIndexPath = commentIndexPath, let indexPath = unwrappedIndexPath {
            let repliesCount = cellData[indexPath.section][indexPath.row].repliesRawCount ?? 0
            cellData[indexPath.section][indexPath.row].repliesRawCount = repliesCount + 1
            cellData[indexPath.section][indexPath.row].repliesCount = (repliesCount + 1).kmFormatted
        }
        var newReplyIndexPath: IndexPath?
        let updatedMessageCount = messageCount + 1
        if let lastReplyViewModel = lastReplyViewModel,
            let indexPath = indexPathOfComment(with: lastReplyViewModel.commentId) {
            let insertionIndex = indexForInsertion(initialIP: indexPath,
            currentReplyDepth: viewModel.depth)
            cellData[indexPath.section].insert(viewModel, at: insertionIndex)
            newReplyIndexPath = IndexPath(row: insertionIndex, section: indexPath.section)
            self.messageCount = updatedMessageCount
            self.messageCounterUpdated?(updatedMessageCount)
        } else {
            let commentViewModel = cellData.flatMap { $0 }.last { $0.commentId == reply.parentId }
            if let commentViewModel = commentViewModel,
                let indexPath = indexPathOfComment(with: commentViewModel.commentId) {
                let insertionIndex = indexForInsertion(initialIP: indexPath,
                                                       currentReplyDepth: viewModel.depth)
                cellData[indexPath.section].insert(viewModel, at: insertionIndex)
                newReplyIndexPath = IndexPath(row: insertionIndex, section: indexPath.section)
                self.messageCount = updatedMessageCount
                self.messageCounterUpdated?(updatedMessageCount)
            }
        }
        cachedCommentReply = nil
        delegate?.reload(scrollToIndexPath: newReplyIndexPath)
    }

    func indexForInsertion(initialIP: IndexPath, currentReplyDepth: Int) -> Int {
        let sectionData = cellData[initialIP.section]
        let count = sectionData.count
        let firstIndex = initialIP.row + 1
        var latestIndexPath: IndexPath?
        for index in firstIndex..<count {
            if sectionData[index].depth <= currentReplyDepth {
                break
            }
            latestIndexPath = IndexPath(row: index + 1, section: initialIP.section)
        }

        return (latestIndexPath ?? IndexPath(row: firstIndex, section: initialIP.section)).row
    }

    func updateEditedCommentAndSendEvent(comment: SPComment, viewModel: CommentViewModel) {
        guard let indexPath = indexPathOfComment(with: comment.id) else { return }
        (cellData[indexPath.section])[indexPath.row] = viewModel
        delegate?.reloadAt(indexPath: indexPath)
        if let commentId = comment.id {
            SPAnalyticsHolder.default.log(
                event: .commentEdited(
                    messageId: commentId,
                    relatedMessageId: viewModel.rootCommentId),
                source: .conversation)
        }
    }

    func isAllCommentAndRepliesShouldBeMuted(_ sectionIndex: Int) -> Bool {
        let sectionData = cellData[sectionIndex]
        for commentVM in sectionData {
            if !commentVM.isCommentAuthorMuted {
                return false
            }
        }
        return true
    }
}

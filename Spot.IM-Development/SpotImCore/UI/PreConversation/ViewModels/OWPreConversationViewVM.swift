//
//  OWPreConversationViewVM.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias PreConversationDataSourceModel = OWAnimatableSectionModel<String, OWPreConversationCellOption>

protocol OWPreConversationViewViewModelingInputs {
    var fullConversationTap: PublishSubject<Void> { get }
    var commentCreationTap: PublishSubject<OWCommentCreationType> { get }
    var viewInitialized: PublishSubject<Void> { get }
}

protocol OWPreConversationViewViewModelingOutputs {
    var reportActionTitle: String { get }
    var viewAccessibilityIdentifier: String { get }
    var preConversationSummaryVM: OWPreConversationSummaryViewModeling { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var commentingCTAViewModel: OWCommentingCTAViewModeling { get }
    var footerViewViewModel: OWPreConversationFooterViewModeling { get }
    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> { get }
    var openFullConversation: Observable<Void> { get }
    var openCommentCreation: Observable<OWCommentCreationType> { get }
    var performTableViewAnimation: Observable<Void> { get }
    var urlClickedOutput: Observable<URL> { get }
    var summaryTopPadding: Observable<CGFloat> { get }
    var shouldShowCommentingCTAView: Observable<Bool> { get }
    var shouldShowComments: Observable<Bool> { get }
    var shouldShowCTAButton: Observable<Bool> { get }
    var shouldShowFooter: Observable<Bool> { get }
    var shouldShowComapactView: Bool { get }
    var conversationCTAButtonTitle: Observable<String> { get }
    var shouldAddContentTapRecognizer: Bool { get }
    var isCompactBackground: Bool { get }
    var compactCommentVM: OWPreConversationCompactContentViewModeling { get }
    var openProfile: Observable<URL> { get }
    var openPublisherProfile: Observable<String> { get }
    var openReportReason: Observable<String> { get }
}

protocol OWPreConversationViewViewModeling: AnyObject {
    var inputs: OWPreConversationViewViewModelingInputs { get }
    var outputs: OWPreConversationViewViewModelingOutputs { get }
}

class OWPreConversationViewViewModel: OWPreConversationViewViewModeling,
                                      OWPreConversationViewViewModelingInputs,
                                      OWPreConversationViewViewModelingOutputs {
    fileprivate struct Metrics {
        static let delayForPerformTableViewAnimation: Int = 10 // ms
        static let delayForUICellUpdate: Int = 100 // ms
        static let viewAccessibilityIdentifier = "pre_conversation_view_@_style_id"
        static let reportActionKey = "Report"
    }

    var inputs: OWPreConversationViewViewModelingInputs { return self }
    var outputs: OWPreConversationViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: OWImageProviding
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    var _cellsViewModels = OWObservableArray<OWPreConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWPreConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> {
        return cellsViewModels
            .map { items in
                // TODO: We might decide to work with few sections in the future.
                // Current implementation will be one section.
                // The String can be the `postId` which we will add once the VM will be ready.
                let section = PreConversationDataSourceModel(model: "postId", items: items)
                return [section]
            }
    }

    lazy var reportActionTitle: String = {
        return OWLocalizationManager.shared.localizedString(key: Metrics.reportActionKey)
    }()

    lazy var viewAccessibilityIdentifier: String = {
        let styleId = (preConversationData.settings.preConversationSettings.style).styleIdentifier
        return Metrics.viewAccessibilityIdentifier.replacingOccurrences(of: "@", with: styleId)
    }()

    lazy var preConversationSummaryVM: OWPreConversationSummaryViewModeling = {
        return OWPreConversationSummaryViewModel(style: preConversationStyle.preConversationSummaryStyle)
    }()

    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel(style: preConversationStyle.communityGuidelinesStyle)
    }()

    lazy var communityQuestionViewModel: OWCommunityQuestionViewModeling = {
        return OWCommunityQuestionViewModel(style: preConversationStyle.communityQuestionStyle)
    }()

    lazy var commentingCTAViewModel: OWCommentingCTAViewModeling = {
        return OWCommentingCTAViewModel(imageProvider: imageProvider)
    }()

    lazy var footerViewViewModel: OWPreConversationFooterViewModeling = {
        return OWPreConversationFooterViewModel()
    }()

    fileprivate lazy var preConversationStyle: OWPreConversationStyle = {
        return self.preConversationData.settings.preConversationSettings.style
    }()

    fileprivate lazy var isCompactMode: Bool = {
        if case .compact = preConversationStyle {
            return true
        }
        return false
    }()

    fileprivate lazy var _preConversationStyle: BehaviorSubject<OWPreConversationStyle> = {
        return BehaviorSubject<OWPreConversationStyle>(value: preConversationStyle)
    }()
    fileprivate lazy var preConversationStyleObservable: Observable<OWPreConversationStyle> = {
        return _preConversationStyle
            .share(replay: 1)
    }()

    fileprivate lazy var isReadOnlyLocalSetting: Bool = {
        return preConversationData.article.additionalSettings.readOnlyMode == .enable
    }()
    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: isReadOnlyLocalSetting)
    fileprivate lazy var isReadOnlyObservable: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    lazy var compactCommentVM: OWPreConversationCompactContentViewModeling = {
        return OWPreConversationCompactContentViewModel(imageProvider: imageProvider)
    }()

    fileprivate lazy var commentsCountObservable: Observable<String> = {
        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { realtimeData in
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(self.postId)") else {return nil}
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? "(\(count.kmFormatted))" : ""
            }
            .asObservable()
    }()

    var conversationCTAButtonTitle: Observable<String> {
        Observable.combineLatest(commentsCountObservable, preConversationStyleObservable, isReadOnlyObservable, isEmpty) { count, style, isReadOnly, isEmpty in
            switch(style) {
            case .regular, .custom:
                return OWLocalizationManager.shared.localizedString(key: "Show more comments")
            case .compact:
                return nil
            case .ctaButtonOnly:
                if isEmpty {
                    return OWLocalizationManager.shared.localizedString(key: "Post a Comment")
                } else {
                    return OWLocalizationManager.shared.localizedString(key: "Show Comments") + " \(count)"
                }
            case .ctaWithSummary:
                if !isEmpty {
                    return OWLocalizationManager.shared.localizedString(key: "Show Comments")
                } else if !isReadOnly {
                    return OWLocalizationManager.shared.localizedString(key: "Post a Comment")
                }
            }
            return nil
        }
        .unwrap()
    }

    var fullConversationTap = PublishSubject<Void>()
    var openFullConversation: Observable<Void> {
        return fullConversationTap
            .asObservable()
    }

    fileprivate var _openProfile = PublishSubject<URL>()
    var openProfile: Observable<URL> {
        return _openProfile
            .asObservable()
    }

    fileprivate var _openPublisherProfile = PublishSubject<String>()
    var openPublisherProfile: Observable<String> {
        return _openPublisherProfile
            .asObservable()
    }

    fileprivate var openReportReasonChange = PublishSubject<String>()
    var openReportReason: Observable<String> {
        return openReportReasonChange
            .asObservable()
    }

    var commentCreationTap = PublishSubject<OWCommentCreationType>()
    var openCommentCreation: Observable<OWCommentCreationType> {
        return commentCreationTap
            .asObservable()
    }

    fileprivate var _performTableViewAnimation = PublishSubject<Void>()
    var performTableViewAnimation: Observable<Void> {
        return _performTableViewAnimation
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    var viewInitialized = PublishSubject<Void>()

    var summaryTopPadding: Observable<CGFloat> {
       preConversationStyleObservable
            .map { style in
                switch(style) {
                case .ctaButtonOnly:
                    return 0
                case .compact:
                    return OWPreConversationView.Metrics.compactSummaryTopPadding
                case .ctaWithSummary, .regular, .custom:
                    return OWPreConversationView.Metrics.summaryTopPadding
                }
            }
    }

    var shouldShowComments: Observable<Bool> {
        Observable.combineLatest(preConversationStyleObservable, isEmpty) { style, isEmpty in
            switch(style) {
            case .regular, .custom:
                return !isEmpty
            case .compact, .ctaWithSummary, .ctaButtonOnly:
                return false
            }
        }
    }

    var shouldShowComapactView: Bool {
        return isCompactMode
    }

    var shouldShowCTAButton: Observable<Bool> {
        Observable.combineLatest(preConversationStyleObservable, isReadOnlyObservable, isEmpty) { style, isReadOnly, isEmpty in
            var isVisible = true
            switch (style) {
            case .regular, .custom:
                isVisible = !isEmpty
            case .ctaButtonOnly, .ctaWithSummary:
                isVisible = !isEmpty || !isReadOnly
            case .compact:
                isVisible = false
            }
            return isVisible
        }
    }

    var shouldShowCommentingCTAView: Observable<Bool> {
        Observable.combineLatest(preConversationStyleObservable, isReadOnlyObservable, isEmpty) { style, isReadOnly, isEmpty in
            switch (style) {
            case .regular, .custom:
                return true
            case .compact:
                return false
            case .ctaWithSummary, .ctaButtonOnly:
                return isReadOnly && isEmpty
            }
        }
    }

    var shouldShowFooter: Observable<Bool> { // TODO: will get from config
        preConversationStyleObservable
            .map { style in
                switch(style) {
                case .compact:
                    return false
                default:
                    return true
                }
            }
    }

    lazy var shouldAddContentTapRecognizer: Bool = {
        return isCompactMode
    }()

    lazy var isCompactBackground: Bool = {
        return isCompactMode
    }()

    fileprivate var isEmpty = BehaviorSubject<Bool>(value: false)

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
        imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
        preConversationData: OWPreConversationRequiredData,
        viewableMode: OWViewableMode) {
            self.servicesProvider = servicesProvider
            self.imageProvider = imageProvider
            self.preConversationData = preConversationData
            self.viewableMode = viewableMode
            self.populateInitialUI()
            setupObservers()
    }
}

fileprivate extension OWPreConversationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {

        // Subscribing to start realtime service
        viewInitialized
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }

                self.servicesProvider.realtimeService().startFetchingData(postId: self.postId)
            })
            .disposed(by: disposeBag)

        // Observable for the sort option
        let sortOptionObservable = self.servicesProvider
            .sortDictateService()
            .sortOption(perPostId: self.postId)

        // Observable for the conversation network API
        let conversationReadObservable = sortOptionObservable
            .flatMapLatest { [weak self] sortOption -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(mode: sortOption, page: OWPaginationPage.first)
                .response
                .materialize() // Required to keep the final subscriber even if errors arrived from the network
            }

        let conversationFetchedObservable = viewInitialized
            .flatMapLatest { _ -> Observable<Event<OWConversationReadRM>> in
                return conversationReadObservable
                    .take(1)
            }
            .map { event -> OWConversationReadRM? in
                switch event {
                case .next(let conversationRead):
                    // TODO: Clear any RX variables which affect error state in the View layer (like _shouldShowError).
                    return conversationRead
                case .error(_):
                    // TODO: handle error - update something like _shouldShowError RX variable which affect the UI state for showing error in the View layer
                    return nil
                default:
                    return nil
                }
            }
            .unwrap()
            .share()

        // Creating the cells VMs for the pre conversation
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard
                    let self = self,
                    let responseComments = response.conversation?.comments,
                    let responseUsers = response.conversation?.users
                else { return }
                var viewModels = [OWPreConversationCellOption]()

                let numOfComments = self.preConversationStyle.numberOfComments
                let comments: [OWComment] = Array(responseComments.prefix(numOfComments))

                // cache comments in comment service
                self.servicesProvider.commentsService().set(comments: responseComments, postId: self.postId)

                // cache users in users service
                self.servicesProvider.usersService().set(users: responseUsers)

                for (index, comment) in comments.enumerated() {
                    guard let user = responseUsers[comment.userId ?? ""] else { return }
                    let vm = OWCommentCellViewModel(data: OWCommentRequiredData(
                        comment: comment,
                        user: user,
                        replyToUser: nil,
                        collapsableTextLineLimit: self.preConversationStyle.collapsableTextLineLimit))
                    viewModels.append(OWPreConversationCellOption.comment(viewModel: vm))
                    if (index < comments.count - 1) {
                        viewModels.append(OWPreConversationCellOption.spacer(viewModel: OWSpacerCellViewModel(style: .comment)))
                    }
                }
                self._cellsViewModels.removeAll()
                self._cellsViewModels.append(contentsOf: viewModels)
            })
            .disposed(by: disposeBag)

        conversationFetchedObservable
            .bind(to: compactCommentVM.inputs.conversationFetched)
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        // Set isEmpty
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] conversation in
                guard let self = self else { return }
                if let messageCount = conversation.conversation?.messagesCount, messageCount > 0 {
                    self.isEmpty.onNext(false)
                } else {
                    self.isEmpty.onNext(true)
                }
            })
            .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.preConversationData.article.additionalSettings.readOnlyMode {
                case .disable:
                    isReadOnly = false
                case .enable:
                    isReadOnly = true
                case .default:
                    break
                }
                self._isReadOnly.onNext(isReadOnly)
            })
            .disposed(by: disposeBag)

        isReadOnlyObservable
            .bind(to: compactCommentVM.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isReadOnlyObservable
            .bind(to: commentingCTAViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .commentCreationTapped
            .subscribe(onNext: { [weak self] in
                self?.commentCreationTap.onNext(.comment)
            })
            .disposed(by: disposeBag)

        // Observable of the comment cell VMs
        let commentCellsVmsObservable: Observable<[OWCommentCellViewModeling]> = cellsViewModels
                    .flatMapLatest { viewModels -> Observable<[OWCommentCellViewModeling]> in
                        let commentCellsVms: [OWCommentCellViewModeling] = viewModels.map { vm in
                            if case.comment(let commentCellViewModel) = vm {
                                return commentCellViewModel
                            } else {
                                return nil
                            }
                        }
                        .unwrap()

                         return Observable.just(commentCellsVms)
                    }
                    .share()

        // Responding to reply click from comment cells VMs
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<OWComment> in
                let replyClickOutputObservable: [Observable<OWComment>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.replyClickedOutput
                        .map { commentVM.outputs.comment }
                }
                return Observable.merge(replyClickOutputObservable)
            }
            .subscribe(onNext: { [weak self] comment in
                self?.commentCreationTap.onNext(.replyToComment(originComment: comment))
            })
            .disposed(by: disposeBag)

        // Responding to share url from comment cells VMs
        commentCellsVmsObservable
            .flatMapLatest { commentCellsVms -> Observable<URL> in
                let shareClickOutputObservable: [Observable<URL>] = commentCellsVms.map { commentCellVm in
                    let commentVM = commentCellVm.outputs.commentVM
                    return commentVM.outputs.commentEngagementVM
                        .outputs.shareCommentUrl
                }
                return Observable.merge(shareClickOutputObservable)
            }
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] shareUrl -> Observable<OWRxPresenterResponseType> in
                guard let self = self else { return .empty() }
                return self.servicesProvider.presenterService()
                    .showActivity(activityItems: [shareUrl], applicationActivities: nil, viewableMode: self.viewableMode)

            }
            .subscribe { result in
                switch result {
                case .completion:
                    // Do nothing
                    break
                case .selected:
                    // Do nothing
                    break
                }
            }
            .disposed(by: disposeBag)

        // Responding to comment avatar click
        let commentAvatarClickObservable: Observable<URL> = commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<URL> in
                let avatarClickOutputObservable: [Observable<URL>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    return avatarVM.outputs.openProfile
                }
                return Observable.merge(avatarClickOutputObservable)
            }

        Observable.merge(commentAvatarClickObservable,
                         commentingCTAViewModel.outputs.openProfile)
            .subscribe(onNext: { [weak self] url in
                self?._openProfile.onNext(url)
            })
            .disposed(by: disposeBag)

        let commentOpenPublisherProfileObservable: Observable<String> = commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<String> in
                let commentOpenPublisherProfileOutput: [Observable<String>] = commentCellsVms.map { commentCellVm in
                    let avatarVM = commentCellVm.outputs.commentVM.outputs.commentHeaderVM.outputs.avatarVM
                    return avatarVM.outputs.openPublisherProfile
                }
                return Observable.merge(commentOpenPublisherProfileOutput)
            }

        Observable.merge(commentOpenPublisherProfileObservable,
                         commentingCTAViewModel.outputs.openPublisherProfile)
            .subscribe(onNext: { [weak self] id in
                self?._openPublisherProfile.onNext(id)
            })
            .disposed(by: disposeBag)

        // Update comments cells on ReadOnly mode
        Observable.combineLatest(commentCellsVmsObservable, isReadOnlyObservable) { commentCellsVms, isReadOnly -> ([OWCommentCellViewModeling], Bool) in
            return (commentCellsVms, isReadOnly)
        }
        .subscribe(onNext: { commentCellsVms, isReadOnly in
            commentCellsVms.forEach {
                $0.outputs.commentVM
                .outputs.commentEngagementVM
                .inputs.isReadOnly
                .onNext(isReadOnly)
            }
        })
        .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Void> in
                let sizeChangeObservable: [Observable<Void>] = cellsVms.map { vm in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.contentVM
                            .outputs.collapsableLabelViewModel.outputs.height
                            .voidify()
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForPerformTableViewAnimation), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._performTableViewAnimation.onNext()
            })
            .disposed(by: disposeBag)

        // Subscribe to URL click in comment text
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<URL> in
                let urlClickObservable: [Observable<URL>] = commentCellsVms.map { commentCellVm -> Observable<URL> in
                    let commentTextVm = commentCellVm.outputs.commentVM.outputs.contentVM.outputs.collapsableLabelViewModel

                    return commentTextVm.outputs.urlClickedOutput
                }
                return Observable.merge(urlClickObservable)
            }
            .subscribe(onNext: { [weak self] url in
                self?._urlClick.onNext(url)
            })
            .disposed(by: disposeBag)

        // Open menu for comment and handle actions
        commentCellsVmsObservable
            .flatMap { commentCellsVms -> Observable<(OWComment, [OWRxPresenterAction])> in
                let openMenuClickObservable: [Observable<(OWComment, [OWRxPresenterAction])>] = commentCellsVms.map { commentCellVm -> Observable<(OWComment, [OWRxPresenterAction])> in
                    let commentVm = commentCellVm.outputs.commentVM
                    let commentHeaderVm = commentVm.outputs.commentHeaderVM

                    return commentHeaderVm.outputs.openMenu
                        .map { (commentVm.outputs.comment, $0) }
                }
                return Observable.merge(openMenuClickObservable)
            }
            // swiftlint:disable unused_closure_parameter
            .subscribe(onNext: { [weak self] comment, actions in
            // swiftlint:enable unused_closure_parameter
                guard let self = self else { return }
                _ = self.servicesProvider.presenterService()
                    .showMenu(actions: actions, viewableMode: self.viewableMode) // TODO: viewableMode
                    .subscribe(onNext: { [weak self] result in
                        guard let self = self else { return }
                        switch result {
                        case .completion:
                            // Do nothing
                            break
                        case .selected(let action):
                            // TODO: handle selection
                            switch action.title {
                            case OWLocalizationManager.shared.localizedString(key: Metrics.reportActionKey):
                                guard let commentId = comment.id else { return }
                                self.openReportReasonChange.onNext(commentId)
                            default: break
                            }
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func populateInitialUI() {
        if !self.isCompactMode {
            let numberOfComments = self.preConversationStyle.numberOfComments
            let skeletonCellVMs = (0 ..< numberOfComments).map { _ in OWCommentSkeletonShimmeringCellViewModel() }
            let skeletonCells = skeletonCellVMs.map { OWPreConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
            _cellsViewModels.append(contentsOf: skeletonCells)
        }
    }
}

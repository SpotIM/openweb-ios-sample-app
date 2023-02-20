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
    // TODO: Testing - remove later and connect the actual views/actions
    var fullConversationTap: PublishSubject<Void> { get }
    var commentCreationTap: PublishSubject<OWCommentCreationType> { get }
    var preConversationChangedSize: PublishSubject<CGSize> { get }

    var viewInitialized: PublishSubject<Void> { get }
}

protocol OWPreConversationViewViewModelingOutputs {
    var preConversationHeaderVM: OWPreConversationHeaderViewModeling { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling { get }
    var footerViewViewModel: OWPreConversationFooterViewModeling { get }
    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> { get }
    var openFullConversation: Observable<Void> { get }
    var openCommentConversation: Observable<OWCommentCreationType> { get }
    var preConversationPreferredSize: Observable<CGSize> { get }
    var changeSizeAtIndex: Observable<Int> { get }
    var urlClickedOutput: Observable<URL> { get }
    var shouldShowCommunityGuidelinesAndQuestion: Bool { get }
    var shouldShowComments: Bool { get }
    var conversationCTAButtonTitle: Observable<String> { get }
}

protocol OWPreConversationViewViewModeling: AnyObject {
    var inputs: OWPreConversationViewViewModelingInputs { get }
    var outputs: OWPreConversationViewViewModelingOutputs { get }
}

class OWPreConversationViewViewModel: OWPreConversationViewViewModeling, OWPreConversationViewViewModelingInputs, OWPreConversationViewViewModelingOutputs {
    var inputs: OWPreConversationViewViewModelingInputs { return self }
    var outputs: OWPreConversationViewViewModelingOutputs { return self }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: OWImageProviding
    fileprivate let preConversationData: OWPreConversationRequiredData
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

    lazy var preConversationHeaderVM: OWPreConversationHeaderViewModeling = {
        return OWPreConversationHeaderViewModel()
    }()

    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel()
    }()

    lazy var communityQuestionViewModel: OWCommunityQuestionViewModeling = {
        return OWCommunityQuestionViewModel()
    }()

    lazy var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling = {
        return OWCommentCreationEntryViewModelV2(imageURLProvider: imageProvider)
    }()

    lazy var footerViewViewModel: OWPreConversationFooterViewModeling = {
        return OWPreConversationFooterViewModel()
    }()

    fileprivate lazy var preConversationStyle: OWPreConversationStyle = {
        return self.preConversationData.settings?.style ?? OWPreConversationStyle.regular()
    }()

    fileprivate lazy var commentsCountObservable: Observable<String> = {
        return OWSharedServicesProvider.shared.realtimeService().realtimeData
            .map { realtimeData in
                guard let count = try? realtimeData.data?.totalCommentsCountForConversation("\(OWManager.manager.spotId)_\(self.postId)") else {return nil}
                return count
            }
            .unwrap()
            .map { count in
                return count > 0 ? "(\(count))" : ""
            }
            .asObservable()
    }()

    var conversationCTAButtonTitle: Observable<String> {
        commentsCountObservable
            .map { [weak self] count in
                guard let self = self else { return nil }
                switch(self.preConversationStyle) {
                case .ctaButtonOnly:
                    return LocalizationManager.localizedString(key: "Show Comments") + " \(count)"
                case .ctaWithSummary:
                    return LocalizationManager.localizedString(key: "Post a Comment")
                default:
                    return LocalizationManager.localizedString(key: "Show more comments")
                }
            }
            .unwrap()
    }

    var fullConversationTap = PublishSubject<Void>()
    var openFullConversation: Observable<Void> {
        return fullConversationTap
            .asObservable()
    }

    var commentCreationTap = PublishSubject<OWCommentCreationType>()
    var openCommentConversation: Observable<OWCommentCreationType> {
        return commentCreationTap
            .asObservable()
    }

    var preConversationChangedSize = PublishSubject<CGSize>()
    // BehaviorSubject required since the size set immediately before subscribers establish
    fileprivate var _preConversationChangedSize = BehaviorSubject<CGSize?>(value: nil)
    var preConversationPreferredSize: Observable<CGSize> {
        return _preConversationChangedSize
            .unwrap()
            .asObservable()
    }

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var changeSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    fileprivate var _urlClick = PublishSubject<URL>()
    var urlClickedOutput: Observable<URL> {
        return _urlClick
            .asObservable()
    }

    var viewInitialized = PublishSubject<Void>()

    var shouldShowCommunityGuidelinesAndQuestion: Bool {
        switch self.preConversationStyle {
        case .regular(_):
            return true
        default:
            return false
        }
    }

    var shouldShowComments: Bool {
        switch self.preConversationStyle {
        case .regular(_):
            return true
        case .compact:
            return true
        default:
            return false
        }
    }

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
        imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
        preConversationData: OWPreConversationRequiredData) {
            self.servicesProvider = servicesProvider
            self.imageProvider = imageProvider
            self.preConversationData = preConversationData
            self.populateInitialUI()
            setupObservers()
    }
}

fileprivate extension OWPreConversationViewViewModel {
    // swiftlint:disable function_body_length
    func setupObservers() {
        preConversationChangedSize
            .bind(to: _preConversationChangedSize)
            .disposed(by: disposeBag)

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
            .flatMap { [weak self] sortOption -> Observable<SPConversationReadRM> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                .netwokAPI()
                .conversation
                .conversationRead(postId: self.postId, mode: sortOption, page: OWPaginationPage.first, parentId: "", offset: 0)
                .response
            }

        let conversationFetchedObservable = viewInitialized
            .flatMap { _ -> Observable<SPConversationReadRM> in
                return conversationReadObservable
                    .take(1)
            }
            .share()

        // Creating the cells VMs for the pre conversation
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self, let responseComments = response.conversation?.comments else { return }
                var viewModels = [OWPreConversationCellOption]()

                let numOfComments = self.preConversationStyle.numberOfComments
                let comments: [SPComment] = Array(responseComments.prefix(numOfComments))

                for (index, comment) in comments.enumerated() {
                    // TODO: replies
                    guard let user = response.conversation?.users?[comment.userId ?? ""] else { return }
                    let vm = OWCommentCellViewModel(data: OWCommentRequiredData(comment: comment, user: user, replyToUser: nil, lineLimit: 4))
                    viewModels.append(OWPreConversationCellOption.comment(viewModel: vm))
                    if (index < comments.count - 1) {
                        viewModels.append(OWPreConversationCellOption.spacer(viewModel: OWSpacerCellViewModel()))
                    }
                }
                self._cellsViewModels.removeAll()
                self._cellsViewModels.append(contentsOf: viewModels)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .map { conversationRead -> SPConversationReadRM? in
                return conversationRead
            }
            .asDriver(onErrorJustReturn: nil)
            .asObservable()
            .unwrap()
            .map { conversation in
                conversation.conversation?.communityQuestion
            }
            .bind(to: communityQuestionViewModel.inputs.communityQuestionString)
            .disposed(by: disposeBag)

        // Subscribing to customize UI related stuff
        Observable.merge(
            preConversationHeaderVM.inputs.customizeCounterLabelUI.asObservable(),
            preConversationHeaderVM.inputs.customizeTitleLabelUI.asObservable()
            )
            .subscribe(onNext: { _ in
//            TODO: custom UI
//            TODO: Map to the appropriate case
            })
            .disposed(by: disposeBag)

        _ = commentCreationEntryViewModel.outputs
            .tapped
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
            .flatMap { commentCellsVms -> Observable<SPComment> in
                let replyClickOutputObservable: [Observable<SPComment>] = commentCellsVms.map { commentCellVm in
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

        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Int> in
                let sizeChangeObservable: [Observable<Int>] = cellsVms.enumerated().map { (index, vm) in
                    if case.comment(let commentCellViewModel) = vm {
                        let commentVM = commentCellViewModel.outputs.commentVM
                        return commentVM.outputs.contentVM
                            .outputs.collapsableLabelViewModel.outputs.textHeightChange
                            .map { index }
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .subscribe(onNext: { [weak self] commentIndex in
                self?._changeSizeAtIndex.onNext(commentIndex)
            })
            .disposed(by: disposeBag)

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
    }
    // swiftlint:enable function_body_length

    func populateInitialUI() {
        if self.shouldShowComments {
            let numberOfComments = self.preConversationStyle.numberOfComments
            let skeletonCellVMs = (0 ..< numberOfComments).map { _ in OWCommentSkeletonShimmeringCellViewModel() }
            let skeletonCells = skeletonCellVMs.map { OWPreConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
            _cellsViewModels.append(contentsOf: skeletonCells)
        }
    }
}

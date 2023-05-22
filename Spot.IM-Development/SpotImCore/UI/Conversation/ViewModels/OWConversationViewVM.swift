//
//  OWConversationViewVM.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

// Our sections is just a string as we will flat all the comments, replies, ads and everything into cells
typealias ConversationDataSourceModel = OWAnimatableSectionModel<String, OWConversationCellOption>

protocol OWConversationViewViewModelingInputs {
    var viewInitialized: PublishSubject<Void> { get }
    var commentCreationTap: PublishSubject<OWCommentCreationType> { get }
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTiTleHeader: Bool { get }
    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling { get }
    var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling { get }
    var shouldShowConversationEmptyState: Observable<Bool> { get }
    var commentingCTAViewModel: OWCommentingCTAViewModel { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var updateCellSizeAtIndex: Observable<Int> { get }
    var openCommentCreation: Observable<OWCommentCreationType> { get }
}

protocol OWConversationViewViewModeling {
    var inputs: OWConversationViewViewModelingInputs { get }
    var outputs: OWConversationViewViewModelingOutputs { get }
}

class OWConversationViewViewModel: OWConversationViewViewModeling,
                                    OWConversationViewViewModelingInputs,
                                    OWConversationViewViewModelingOutputs {
    var inputs: OWConversationViewViewModelingInputs { return self }
    var outputs: OWConversationViewViewModelingOutputs { return self }

    fileprivate struct Metrics {
        static let delayForCellSizeChanges: Int = 100
    }

    var viewInitialized = PublishSubject<Void>()

    var commentCreationTap = PublishSubject<OWCommentCreationType>()
    var openCommentCreation: Observable<OWCommentCreationType> {
        return commentCreationTap
            .asObservable()
    }

    var shouldShowTiTleHeader: Bool {
        return viewableMode == .independent
    }

    lazy var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling = {
        return OWConversationTitleHeaderViewModel()
    }()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel(article: conversationData.article)
    }()

    lazy var conversationSummaryViewModel: OWConversationSummaryViewModeling = {
        return OWConversationSummaryViewModel()
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle)
    }()

    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    lazy var conversationEmptyStateCellViewModel: OWConversationEmptyStateCellViewModeling = {
//        return OWConversationEmptyStateCellViewModel()
//    }()

    lazy var conversationEmptyStateViewModel: OWConversationEmptyStateViewModeling = {
        return OWConversationEmptyStateViewModel()
    }()

    fileprivate let _shouldShowConversationEmptyState = BehaviorSubject<Bool>(value: false)
    var shouldShowConversationEmptyState: Observable<Bool> {
        return _shouldShowConversationEmptyState
            .asObservable()
    }

    lazy var commentingCTAViewModel: OWCommentingCTAViewModel = {
        return OWCommentingCTAViewModel(imageProvider: imageProvider)
    }()

    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> {
        return cellsViewModels
            .map { items in
                // TODO: We might decide to work with few sections in the future.
                // Current implementation will be one section.
                // The String can be the `postId` which we will add once the VM will be ready.
                let section = ConversationDataSourceModel(model: "postId", items: items)
                return [section]
            }
    }

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var updateCellSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    fileprivate var _cellsViewModels = OWObservableArray<OWConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

    fileprivate lazy var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling = {
        return OWCommunityQuestionCellViewModel(style: conversationStyle.communityQuestionStyle)
    }()

    fileprivate lazy var spacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .none)
    }()

    fileprivate lazy var communitySpacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .community)
    }()

    fileprivate lazy var communityQuestionCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityQuestion(viewModel: communityQuestionCellViewModel)
    }()

    fileprivate lazy var communityGuidelinesCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityGuidelines(viewModel: communityGuidelinesCellViewModel)
    }()

    // TODO: Decide if we need an OWConversationEmptyStateCell after final design in all orientations
//    fileprivate lazy var conversationEmptyStateCellOption: OWConversationCellOption = {
//        return OWConversationCellOption.conversationEmptyState(viewModel: conversationEmptyStateCellViewModel)
//    }()

    fileprivate lazy var communitySpacerCellOption: OWConversationCellOption = {
        return OWConversationCellOption.spacer(viewModel: communitySpacerCellViewModel)
    }()

    fileprivate lazy var conversationStyle: OWConversationStyle = {
        return self.conversationData.settings?.style ?? OWConversationStyle.regular
    }()

    fileprivate lazy var isReadOnly: Bool = {
        return conversationData.article.additionalSettings.readOnlyMode == .enable
    }()
    fileprivate lazy var _isReadOnly = BehaviorSubject<Bool>(value: isReadOnly)
    fileprivate lazy var isReadOnlyObservable: Observable<Bool> = {
        return _isReadOnly
            .share(replay: 1)
    }()

    fileprivate var _isEmpty = BehaviorSubject<Bool>(value: false)
    fileprivate lazy var isEmptyObservable: Observable<Bool> = {
        return _isEmpty
            .share(replay: 1)
    }()

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: OWImageProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          imageProvider: OWImageProviding = OWCloudinaryImageProvider(),
          conversationData: OWConversationRequiredData,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.imageProvider = imageProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()
        self.populateInitialUI()
    }
}

fileprivate extension OWConversationViewViewModel {
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

        // Set isEmpty
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] conversation in
                guard let self = self else { return }
                if let messageCount = conversation.conversation?.messagesCount, messageCount > 0 {
                    self._isEmpty.onNext(false)
                } else {
                    self._isEmpty.onNext(true)
                }
            })
            .disposed(by: disposeBag)

        // Set read only mode
        conversationFetchedObservable
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                var isReadOnly: Bool = response.conversation?.readOnly ?? false
                switch self.conversationData.article.additionalSettings.readOnlyMode {
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
            .bind(to: commentingCTAViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isReadOnlyObservable
            .bind(to: conversationEmptyStateViewModel.inputs.isReadOnly)
            .disposed(by: disposeBag)

        isEmptyObservable
            .bind(to: conversationEmptyStateViewModel.inputs.isEmpty)
            .disposed(by: disposeBag)

        commentingCTAViewModel
            .outputs
            .commentCreationTapped
            .subscribe(onNext: { [weak self] in
                self?.commentCreationTap.onNext(.comment)
            })
            .disposed(by: disposeBag)

        // Binding to community question component
        conversationFetchedObservable
            .bind(to: communityQuestionCellViewModel.outputs.communityQuestionViewModel.inputs.conversationFetched)
            .disposed(by: disposeBag)

        let shouldShowCommunityQuestion = communityQuestionCellViewModel.outputs
            .communityQuestionViewModel.outputs
            .shouldShowView

        let shouldShowCommunityGuidelines = communityGuidelinesCellViewModel.outputs
            .communityGuidelinesViewModel.outputs
            .shouldShowView

        // Responding to guidelines height change (for updating cell)
        cellsViewModels
            .flatMapLatest { cellsVms -> Observable<Int> in
                let sizeChangeObservable: [Observable<Int>] = cellsVms.enumerated().map { (index, vm) in
                    if case.communityGuidelines(let guidelinesCellViewModel) = vm {
                        let guidelinesVM = guidelinesCellViewModel.outputs.communityGuidelinesViewModel
                        return guidelinesVM.outputs.shouldShowViewAfterHeightChanged
                            .filter { $0 == true }
                            .map { _ in index }
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(Metrics.delayForCellSizeChanges), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] guidelinesIndex in
                self?._changeSizeAtIndex.onNext(guidelinesIndex)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(conversationFetchedObservable,
                                 shouldShowCommunityQuestion,
                                 shouldShowCommunityGuidelines,
                                 isEmptyObservable)
            .subscribe(onNext: { [weak self] (_, shouldShowCommunityQuestion, shouldShowCommunityGuidelines, isEmpty) -> Void in
            guard let self = self else { return }
                self._cellsViewModels.removeAll()

                var cellsToApped = [OWConversationCellOption]()

                switch (shouldShowCommunityQuestion, shouldShowCommunityGuidelines) {
                case (true, true):
                    cellsToApped.append(contentsOf: [self.communityQuestionCellOption,
                                                     self.communitySpacerCellOption,
                                                     self.communityGuidelinesCellOption])
                case (true, false):
                    cellsToApped.append(self.communityQuestionCellOption)
                case (false, true):
                    cellsToApped.append(self.communityGuidelinesCellOption)
                default:
                    break
                }

                if !isEmpty {
                    // Should be removed when adding comments
                    let skeletonsCellsModels = self.getSkeletonsCellsModels()
                    cellsToApped.append(contentsOf: skeletonsCellsModels)
                }

                self._cellsViewModels.append(contentsOf: cellsToApped)

                self._shouldShowConversationEmptyState.onNext(isEmpty)
        })
        .disposed(by: disposeBag)
    }
    // swiftlint:enable function_body_length

    func getSkeletonsCellsModels() -> [OWConversationCellOption] {
        // TODO: Delete once working on the conversation view UI
        let skeletonCellVMs = (0 ..< 50).map { _ in
            return OWCommentSkeletonShimmeringCellViewModel()
        }
        return skeletonCellVMs.map { OWConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
    }

    func populateInitialUI() {
        // TODO: Delete once working on the conversation view UI
        let skeletonsCellsModels = getSkeletonsCellsModels()
        _cellsViewModels.append(contentsOf: skeletonsCellsModels)
    }
}

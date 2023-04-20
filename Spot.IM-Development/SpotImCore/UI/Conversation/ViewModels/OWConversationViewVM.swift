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
}

protocol OWConversationViewViewModelingOutputs {
    var shouldShowTiTleHeader: Bool { get }
    var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling { get }
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get }
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var updateCellSizeAtIndex: Observable<Int> { get }
    var initialDataLoaded: Observable<Bool> { get }
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

    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let conversationData: OWConversationRequiredData
    fileprivate let viewableMode: OWViewableMode
    fileprivate let disposeBag = DisposeBag()

    lazy var conversationTitleHeaderViewModel: OWConversationTitleHeaderViewModeling = {
        return OWConversationTitleHeaderViewModel()
    }()

    lazy var articleDescriptionViewModel: OWArticleDescriptionViewModeling = {
        return OWArticleDescriptionViewModel(article: conversationData.article)
    }()

    lazy var conversationSummaryViewModel: OWConversationSummaryViewModeling = {
        return OWConversationSummaryViewModel()
    }()

    lazy var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling = {
        return OWCommunityQuestionCellViewModel(style: conversationStyle.communityQuestionStyle)
    }()

    lazy var spacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .none)
    }()

    lazy var communitySpacerCellViewModel: OWSpacerCellViewModeling = {
        return OWSpacerCellViewModel(style: .community)
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle)
    }()

    fileprivate lazy var communityQuestionCellOptions: OWConversationCellOption = {
        return OWConversationCellOption.communityQuestion(viewModel: communityQuestionCellViewModel)
    }()

    fileprivate lazy var communityGuidelinesCellOption: OWConversationCellOption = {
        return OWConversationCellOption.communityGuidelines(viewModel: communityGuidelinesCellViewModel)
    }()

    fileprivate lazy var communitySpacerCellOption: OWConversationCellOption = {
        return OWConversationCellOption.spacer(viewModel: communitySpacerCellViewModel)
    }()

    var _cellsViewModels = OWObservableArray<OWConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }

    fileprivate var _changeSizeAtIndex = PublishSubject<Int>()
    var updateCellSizeAtIndex: Observable<Int> {
        return _changeSizeAtIndex
            .asObservable()
    }

    fileprivate var _initialDataLoaded = BehaviorSubject<Bool>(value: false)
    var initialDataLoaded: Observable<Bool> {
        return _initialDataLoaded
            .asObservable()
    }

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

    fileprivate lazy var conversationStyle: OWConversationStyle = {
        return self.conversationData.settings?.style ?? OWConversationStyle.regular
    }()

    var shouldShowTiTleHeader: Bool {
        return viewableMode == .independent
    }

    var viewInitialized = PublishSubject<Void>()

    fileprivate var postId: OWPostId {
        return OWManager.manager.postId ?? ""
    }

    init (servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
          conversationData: OWConversationRequiredData,
          viewableMode: OWViewableMode) {
        self.servicesProvider = servicesProvider
        self.conversationData = conversationData
        self.viewableMode = viewableMode
        setupObservers()
        self.populateInitialUI()
    }
}

fileprivate extension OWConversationViewViewModel {
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
                        return guidelinesVM.outputs.shouldShowViewExternaly
                            .filter { $0 == true }
                            .map { _ in index }
                    } else {
                        return nil
                    }
                }
                .unwrap()
                return Observable.merge(sizeChangeObservable)
            }
            .delay(.milliseconds(50), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] guidelinesIndex in
                self?._changeSizeAtIndex.onNext(guidelinesIndex)
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(conversationFetchedObservable,
                                 shouldShowCommunityQuestion,
                                 shouldShowCommunityGuidelines)
            .subscribe(onNext: { [weak self] (_, shouldShowCommunityQuestion, shouldShowCommunityGuidelines) -> Void in
            guard let self = self else { return }
                self._cellsViewModels.removeAll()

                var cellsToApped = [OWConversationCellOption]()

                switch (shouldShowCommunityQuestion, shouldShowCommunityGuidelines) {
                case (true, true):
                    cellsToApped.append(contentsOf: [self.communityQuestionCellOptions,
                                                     self.communitySpacerCellOption,
                                                     self.communityGuidelinesCellOption])
                case (true, false):
                    cellsToApped.append(self.communityQuestionCellOptions)
                case (false, true):
                    cellsToApped.append(self.communityGuidelinesCellOption)
                default:
                    break
                }

                let skeletons = self.getInitialUI()
                cellsToApped.append(contentsOf: skeletons)

                self._cellsViewModels.append(contentsOf: cellsToApped)
                self._initialDataLoaded.onNext(true)
        })
        .disposed(by: disposeBag)
    }

    func getInitialUI() -> [OWConversationCellOption] {
        // TODO: Delete once working on the conversation view UI
        let skeletonCellVMs = (0 ..< 50).map { _ in
            return OWCommentSkeletonShimmeringCellViewModel()
        }
        return skeletonCellVMs.map { OWConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
    }

    func populateInitialUI() {
        // TODO: Delete once working on the conversation view UI
        let skeletons = getInitialUI()
        _cellsViewModels.append(contentsOf: skeletons)
    }
}

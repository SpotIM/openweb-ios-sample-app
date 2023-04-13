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
    var articleDescriptionViewModel: OWArticleDescriptionViewModeling { get }
    var conversationSummaryViewModel: OWConversationSummaryViewModeling { get }
    var communityQuestionCellViewModel: OWCommunityQuestionCellViewModeling { get }
    var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling { get}
    var conversationDataSourceSections: Observable<[ConversationDataSourceModel]> { get }
    var updateCellSizeAtIndex: Observable<Int> { get }
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
        return OWSpacerCellViewModel()
    }()

    lazy var communityGuidelinesCellViewModel: OWCommunityGuidelinesCellViewModeling = {
        return OWCommunityGuidelinesCellViewModel(style: conversationStyle.communityGuidelinesStyle)
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
        self.populateInitialUI()
        setupObservers()
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

//        conversationFetchedObservable
//            .subscribe(onNext: { conversation in
//                print(conversation)
//            })
//            .disposed(by: disposeBag)

        // Responding to comment height change (for updating cell)
        communityQuestionCellViewModel
            .outputs.communityQuestionViewModel
            .outputs.shouldShowView
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._changeSizeAtIndex.onNext(0)
            })
            .disposed(by: disposeBag)

        communityGuidelinesCellViewModel
            .outputs.communityGuidelinesViewModel
            .outputs.shouldShowView
            .delay(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?._changeSizeAtIndex.onNext(2)
            })
            .disposed(by: disposeBag)
    }

    func populateInitialUI() {
        let communityQuestionCellVM = OWConversationCellOption.communityQuestion(viewModel: communityQuestionCellViewModel)
        _cellsViewModels.append(communityQuestionCellVM)

        let spacerVM = OWConversationCellOption.spacer(viewModel: spacerCellViewModel)
        _cellsViewModels.append(spacerVM)

        let communityGuidelinesCellVM = OWConversationCellOption.communityGuidelines(viewModel: communityGuidelinesCellViewModel)
        _cellsViewModels.append(communityGuidelinesCellVM)

        // TODO: Delete once working on the conversation view UI
        let skeletonCellVMs = (0 ..< 50).map { _ in
            return OWCommentSkeletonShimmeringCellViewModel()
        }
        let skeletonCells = skeletonCellVMs.map { OWConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
        _cellsViewModels.append(contentsOf: skeletonCells)
    }
}

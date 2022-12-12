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
    var commentCreationTap: PublishSubject<Void> { get }
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
    var isButtonOnlyModeEnabled: Bool { get }
    var openFullConversation: Observable<Void> { get }
    var openCommentConversation: Observable<Void> { get }
    var preConversationPreferredSize: Observable<CGSize> { get }
}

protocol OWPreConversationViewViewModeling: AnyObject {
    var inputs: OWPreConversationViewViewModelingInputs { get }
    var outputs: OWPreConversationViewViewModelingOutputs { get }
}

class OWPreConversationViewViewModel: OWPreConversationViewViewModeling, OWPreConversationViewViewModelingInputs, OWPreConversationViewViewModelingOutputs {    
    var inputs: OWPreConversationViewViewModelingInputs { return self }
    var outputs: OWPreConversationViewViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: SPImageProvider
    fileprivate let preConversationData: OWPreConversationRequiredData
    fileprivate let disposeBag = DisposeBag()
    
    var _cellsViewModels = OWObservableArray<OWPreConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWPreConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
    }
    
    fileprivate var numberOfMessagesToShow: Int {
        return preConversationData.settings?.numberOfComments ?? 2
    }
    
    var isButtonOnlyModeEnabled: Bool {
        self.numberOfMessagesToShow == 0 || SpotIm.buttonOnlyMode.isEnabled()
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
    
    
    var fullConversationTap = PublishSubject<Void>()
    var openFullConversation: Observable<Void> {
        return fullConversationTap
            .asObservable()
    }
    
    var commentCreationTap = PublishSubject<Void>()
    var openCommentConversation: Observable<Void> {
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
    
    var viewInitialized = PublishSubject<Void>()

    init (
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
        imageProvider: SPImageProvider = SPCloudinaryImageProvider(apiManager: OWApiManager()),
        preConversationData: OWPreConversationRequiredData) {
            self.servicesProvider = servicesProvider
            self.imageProvider = imageProvider
            self.preConversationData = preConversationData
            let skeletonCellVMs = (0 ..< numberOfMessagesToShow).map { _ in
                return OWCommentSkeletonShimmeringCellViewModel()
            }
            let skeletonCells = skeletonCellVMs.map { OWPreConversationCellOption.commentSkeletonShimmering(viewModel: $0) }
            _cellsViewModels.append(contentsOf: skeletonCells)
            setupObservers()
    }
}

fileprivate extension OWPreConversationViewViewModel {
    func setupObservers() {
        preConversationChangedSize
            .bind(to: _preConversationChangedSize)
            .disposed(by: disposeBag)
        
        viewInitialized
            .subscribe(onNext: { [weak self] in
                guard let self = self,
                      let postId = OWManager.manager.postId
                else { return }
                
                self.servicesProvider.realtimeService().startFetchingData(postId: postId)
            })
            .disposed(by: disposeBag)
        
        viewInitialized
            .flatMap { [weak self] _ -> Observable<SPConversationReadRM?> in
                guard let self = self,
                      let postId = OWManager.manager.postId else { return .empty() }
                
                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(postId: postId, mode: SPCommentSortMode.newest, page: SPPaginationPage.first, parentId: "", offset: 0)
                    .response
                    .map { response -> SPConversationReadRM? in
                        guard let comments = response.conversation?.comments else { return nil }
                        var viewModels = [OWPreConversationCellOption]()
                        for comment in comments.prefix(self.numberOfMessagesToShow) {
                            let vm = OWCommentCellViewModel(comment: comment, user: response.conversation?.users?[comment.userId ?? ""])
                            viewModels.append(OWPreConversationCellOption.comment(viewModel: vm))
                        }
                        self._cellsViewModels.removeAll()
                        self._cellsViewModels.append(contentsOf: viewModels)
                        return response
                    }
            }
            .asDriver(onErrorJustReturn: nil)
            .asObservable()
            .unwrap()
            .map { conversation in
                conversation.conversation?.communityQuestion
            }
            .bind(to: communityQuestionViewModel.inputs.communityQuestionString)
            .disposed(by: disposeBag)
        
        Observable.merge(
            preConversationHeaderVM.inputs.customizeCounterLabelUI.asObservable(),
            preConversationHeaderVM.inputs.customizeTitleLabelUI.asObservable()
        )
            .bind(onNext: { label in
//            TODO: custom UI
//            TODO: Map to the appropriate case
            })
            .disposed(by: disposeBag)
        
        _ = commentCreationEntryViewModel.outputs
            .tapped
            .bind(to: commentCreationTap)
            .disposed(by: disposeBag)
    }
}

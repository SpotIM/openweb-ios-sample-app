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
typealias PreConversationDataSourceModel = OWAnimatableSectionModel<String, OWConversationCellOption>

protocol OWPreConversationViewViewModelingInputs {
    
}

protocol OWPreConversationViewViewModelingOutputs {
    var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling { get }
    var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling { get }
    var communityQuestionViewModel: OWCommunityQuestionViewModeling { get }
    var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling { get }
    var footerViewViewModel: OWPreConversationFooterViewModeling { get }
    var preConversationDataSourceSections: Observable<[PreConversationDataSourceModel]> { get }
    var isButtonOnlyModeEnabled: Bool { get }
}

protocol OWPreConversationViewViewModeling {
    var inputs: OWPreConversationViewViewModelingInputs { get }
    var outputs: OWPreConversationViewViewModelingOutputs { get }
}

class OWPreConversationViewViewModel: OWPreConversationViewViewModeling, OWPreConversationViewViewModelingInputs, OWPreConversationViewViewModelingOutputs {    
    var inputs: OWPreConversationViewViewModelingInputs { return self }
    var outputs: OWPreConversationViewViewModelingOutputs { return self }
    
    fileprivate let servicesProvider: OWSharedServicesProviding
    fileprivate let imageProvider: SPImageProvider
    fileprivate let numberOfMessagesToShow: Int
    
    var _cellsViewModels = OWObservableArray<OWConversationCellOption>()
    fileprivate var cellsViewModels: Observable<[OWConversationCellOption]> {
        return _cellsViewModels
            .rx_elements()
            .asObservable()
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
    
    lazy var onlineViewingUsersVM: OWOnlineViewingUsersCounterViewModeling = {
        return OWOnlineViewingUsersCounterViewModel()
    }()
    
    lazy var communityGuidelinesViewModel: OWCommunityGuidelinesViewModeling = {
        return OWCommunityGuidelinesViewModel()
    }()
    
    lazy var communityQuestionViewModel: OWCommunityQuestionViewModeling = {
        return OWCommunityQuestionViewModel()
    }()
    
    lazy var commentCreationEntryViewModel: OWCommentCreationEntryViewModeling = {
        return OWCommentCreationEntryViewModel(imageURLProvider: imageProvider)
    }()
    
    lazy var footerViewViewModel: OWPreConversationFooterViewModeling = {
        return OWPreConversationFooterViewModel()
    }()

    init (
        servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
        imageProvider: SPImageProvider,
        settings: OWPreConversationSettings) {
            self.servicesProvider = servicesProvider
            self.imageProvider = imageProvider
            self.numberOfMessagesToShow = settings.numberOfComments
            setupObservers()
    }
}

fileprivate extension OWPreConversationViewViewModel {
    func setupObservers() {
        
    }
}

//
//  OWCommunityGuidelinesViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 27/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWCommunityGuidelinesViewModelingInputs {
    
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var communityGuidelinesHtmlText: Observable<String?> { get }
    var showSeparator: Observable<Bool> { get }
}

protocol OWCommunityGuidelinesViewModeling {
    var inputs: OWCommunityGuidelinesViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { get }
}

class OWCommunityGuidelinesViewModel: OWCommunityGuidelinesViewModeling, OWCommunityGuidelinesViewModelingInputs, OWCommunityGuidelinesViewModelingOutputs {
    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }
    
    var communityGuidelinesHtmlText: Observable<String?> {
        OWSharedServicesProvider.shared.spotConfigurationService().config(spotId: OWManager.manager.spotId)
            .map { config in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled ?? false else { return nil}
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { [weak self] communityGuidelines in
                return self?.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelines)
            }
            .asObservable()
    }
    
    fileprivate var _showSeparator = BehaviorSubject<Bool>(value: true)
    var showSeparator: Observable<Bool> {
        return _showSeparator
            .asObservable()
    }
    
}

extension OWCommunityGuidelinesViewModel {
    private func getCommunityGuidelinesHtmlString(communityGuidelinesTitle: String) -> String {
        var htmlString = communityGuidelinesTitle
        
        // remove <p> and </p> tags to control the text height by the sdk
        htmlString = htmlString.replacingOccurrences(of: "<p>", with: "")
        htmlString = htmlString.replacingOccurrences(of: "</p>", with: "")
        
        return htmlString
    }
}

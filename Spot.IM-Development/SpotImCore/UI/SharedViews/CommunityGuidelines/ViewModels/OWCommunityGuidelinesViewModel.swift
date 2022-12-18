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
    var urlClicked: PublishSubject<URL> { get }
}

protocol OWCommunityGuidelinesViewModelingOutputs {
    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> { get }
    var urlClickedOutput: Observable<URL> { get }
}

protocol OWCommunityGuidelinesViewModeling {
    var inputs: OWCommunityGuidelinesViewModelingInputs { get }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { get }
}

class OWCommunityGuidelinesViewModel: OWCommunityGuidelinesViewModeling, OWCommunityGuidelinesViewModelingInputs, OWCommunityGuidelinesViewModelingOutputs {
    struct Metrics {
        static let communityGuidelinesFontSize = 15.0
    }
    
    var inputs: OWCommunityGuidelinesViewModelingInputs { return self }
    var outputs: OWCommunityGuidelinesViewModelingOutputs { return self }
    
    let urlClicked = PublishSubject<URL>()
    
    var urlClickedOutput: Observable<URL> {
        urlClicked.asObservable()
    }
    
    var communityGuidelinesHtmlAttributedString: Observable<NSAttributedString?> {
        OWSharedServicesProvider.shared.spotConfigurationService()
            .config(spotId: OWManager.manager.spotId)
            .observe(on: SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: "OpenWebSDKCommunityGuidelinesVMQueue"))
            .map { config -> String? in
                guard let conversationConfig = config.conversation,
                      conversationConfig.communityGuidelinesEnabled == true else { return nil }
                return config.conversation?.communityGuidelinesTitle?.value
            }
            .unwrap()
            .map { [weak self] communityGuidelines in
                guard let self = self else { return nil }
                let string = self.getCommunityGuidelinesHtmlString(communityGuidelinesTitle: communityGuidelines)
                return self.getTitleTextViewAttributedText(htmlString: string)
            }
            .observe(on: MainScheduler.instance)
            .asObservable()
    }
}

fileprivate extension OWCommunityGuidelinesViewModel {
    func getCommunityGuidelinesHtmlString(communityGuidelinesTitle: String) -> String {
        var htmlString = communityGuidelinesTitle
        
        // remove <p> and </p> tags to control the text height by the sdk
        htmlString = htmlString.replacingOccurrences(of: "<p>", with: "")
        htmlString = htmlString.replacingOccurrences(of: "</p>", with: "")
        
        return htmlString
    }
    
    func getTitleTextViewAttributedText(htmlString: String) -> NSMutableAttributedString? {
        if let htmlMutableAttributedString = htmlString.htmlToMutableAttributedString {
            htmlMutableAttributedString.addAttribute(
                .font,
                value: UIFont.preferred(style: .medium, of: Metrics.communityGuidelinesFontSize),
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .underlineStyle,
                value: NSNumber(value: false),
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            htmlMutableAttributedString.addAttribute(
                .foregroundColor,
                value: UIColor.spForeground0,
                range: NSMakeRange(0, htmlMutableAttributedString.length)
            )
            return htmlMutableAttributedString
        } else {
            return nil
        }
    }
}

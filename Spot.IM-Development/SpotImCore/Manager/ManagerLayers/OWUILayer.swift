//
//  OWUILayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWUILayer: OWUI, OWUIFlows, OWUIViews {
    var flows: OWUIFlows { return self }
    var views: OWUIViews { return self }
    var helpers: OWHelpers { return self._helpers }
    
    fileprivate let sdkCoordinator: OWSDKCoordinator
    fileprivate let _helpers: OWHelpers
    
    init(sdkCoordinator: OWSDKCoordinator = OWSDKCoordinator(),
         helpers: OWHelpers = OWHelpersInternal()) {
        self.sdkCoordinator = sdkCoordinator
        self._helpers = helpers
    }
    
    func preConversation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWPreConversationSettingsProtocol? = nil,
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWViewDynamicSizeCompletion) {
        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }
    }
    
    func conversation(postId: String, article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWConversationSettingsProtocol? = nil,
                      callbacks: OWViewActionsCallbacks? = nil,
                      completion: @escaping OWDefaultCompletion) {
        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }
        
        let conversationData = OWConversationRequiredData(article: article,
                                                          settings: additionalSettings)
        
        _ = sdkCoordinator.startConversationFlow(conversationData: conversationData,
                                                 presentationalMode: presentationalMode,
                                                 callbacks: callbacks)
            .take(1)
            .subscribe(onNext: { _ in
                completion(.success(()))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.conversationFlow
                completion(.failure(error))
            })
    }
    
    func commentCreation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWCommentSettingsProtocol? = nil,
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWDefaultCompletion) {
        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }
        
    }
}

fileprivate extension OWUILayer {
    func setPostId(postId: String, completion: @escaping OWDefaultCompletion) {
        guard let manager = OpenWeb.manager as? OWManagerInternalProtocol else {
            let error = OWError.castingError(description: "OpenWeb.manager casting to OWManagerInternalProtocol failed")
            completion(.failure(error))
            return
        }
        
        manager.postId = postId
    }
}

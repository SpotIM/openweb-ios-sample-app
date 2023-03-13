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
    var customizations: OWCustomizations { return self._customizations }
    var authenticationUI: OWUIAuthentication { return self._authenticationUI }

    fileprivate let sdkCoordinator: OWSDKCoordinator
    fileprivate let _customizations: OWCustomizations
    fileprivate let _authenticationUI: OWUIAuthentication
    fileprivate var flowDisposeBag: DisposeBag!

    init(sdkCoordinator: OWSDKCoordinator = OWSDKCoordinator(),
         customizations: OWCustomizations = OWCustomizationsLayer(),
         authenticationUI: OWUIAuthentication = OWUIAuthenticationLayer()) {
        self.sdkCoordinator = sdkCoordinator
        self._customizations = customizations
        self._authenticationUI = authenticationUI
    }

    func preConversation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWPreConversationSettingsProtocol? = nil,
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWViewCompletion) {
        prepareForNewFlow()

        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        let preConversationData = OWPreConversationRequiredData(article: article,
                                                                settings: additionalSettings)

        sdkCoordinator.startPreConversationFlow(preConversationData: preConversationData,
                                                presentationalMode: presentationalMode,
                                                callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.conversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func conversation(postId: String, article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWConversationSettingsProtocol? = nil,
                      callbacks: OWViewActionsCallbacks? = nil,
                      completion: @escaping OWDefaultCompletion) {
        prepareForNewFlow()

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
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { result in
            switch result {
            case .loadedToScreen:
                completion(.success(()))
            default:
                break
            }
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.conversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func commentCreation(postId: String, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWCommentCreationSettingsProtocol? = nil,
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWDefaultCompletion) {
        prepareForNewFlow()

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
                                                          settings: additionalSettings?.conversationSettings)
        let commentCreationData = OWCommentCreationRequiredData(article: article, commentCreationType: .comment)

        _ = sdkCoordinator.startCommentCreationFlow(conversationData: conversationData,
                                                    commentCreationData: commentCreationData,
                                                    presentationalMode: presentationalMode,
                                                    callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { result in
            switch result {
            case .loadedToScreen:
                completion(.success(()))
            default:
                break
            }
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.conversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       presentationalMode: OWPresentationalMode,
                       additionalSettings: OWCommentThreadSettingsProtocol? = nil,
                       callbacks: OWViewActionsCallbacks? = nil,
                       completion: @escaping OWDefaultCompletion) {
        prepareForNewFlow()

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
                                                          settings: additionalSettings?.conversationSettings)
        let commentThreadData = OWCommentThreadRequiredData(article: article, commentId: commentId)

        _ = sdkCoordinator.startCommentThreadFlow(conversationData: conversationData,
                                                    commentThreadData: commentThreadData,
                                                    presentationalMode: presentationalMode,
                                                    callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { result in
            switch result {
            case .loadedToScreen:
                completion(.success(()))
            default:
                break
            }
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.conversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
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

    func prepareForNewFlow() {
        // Discard any previous subscription to other flows
        flowDisposeBag = DisposeBag()
    }
}

//
//  OWUILayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWUILayer: OWUI, OWUIFlows, OWUIViews, OWRouteringCompatible, OWCompactRouteringCompatible {
    var flows: OWUIFlows { return self }
    var views: OWUIViews { return self }
    var customizations: OWCustomizations { return self._customizations }
    var authenticationUI: OWUIAuthentication { return self._authenticationUI }

    var routering: OWRoutering {
        return flowsSdkCoordinator.routering
    }

    var compactRoutering: OWCompactRoutering {
        return viewsSdkCoordinator.compactRoutering
    }

    fileprivate let flowsSdkCoordinator: OWFlowsSDKCoordinator
    fileprivate let viewsSdkCoordinator: OWViewsSDKCoordinator
    fileprivate let _customizations: OWCustomizations
    fileprivate let _authenticationUI: OWUIAuthentication
    fileprivate var flowDisposeBag: DisposeBag!

    init(flowsSdkCoordinator: OWFlowsSDKCoordinator = OWFlowsSDKCoordinator(),
         viewsSdkCoordinator: OWViewsSDKCoordinator = OWViewsSDKCoordinator(),
         customizations: OWCustomizations = OWCustomizationsLayer(),
         authenticationUI: OWUIAuthentication = OWUIAuthenticationLayer()) {
        self.flowsSdkCoordinator = flowsSdkCoordinator
        self.viewsSdkCoordinator = viewsSdkCoordinator
        self._customizations = customizations
        self._authenticationUI = authenticationUI
    }
}

// UIFlows
extension OWUILayer {
    func preConversation(postId: OWPostId, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
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
                                                                settings: additionalSettings,
                                                                presentationalStyle: presentationalMode.style)

        flowsSdkCoordinator.startPreConversationFlow(preConversationData: preConversationData,
                                                presentationalMode: presentationalMode,
                                                callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.preConversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func conversation(postId: OWPostId, article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
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
                                                          settings: additionalSettings,
                                                          presentationalStyle: presentationalMode.style)

        _ = flowsSdkCoordinator.startConversationFlow(conversationData: conversationData,
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

    func commentCreation(postId: OWPostId, article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
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
                                                          settings: additionalSettings,
                                                          presentationalStyle: presentationalMode.style)
        let commentCreationData = OWCommentCreationRequiredData(article: article, settings: additionalSettings, commentCreationType: .comment)

        _ = flowsSdkCoordinator.startCommentCreationFlow(conversationData: conversationData,
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
            let error: OWError = err as? OWError ?? OWError.commentCreationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       presentationalMode: OWPresentationalMode,
                       additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
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
                                                          settings: additionalSettings,
                                                          presentationalStyle: presentationalMode.style)
        let commentThreadData = OWCommentThreadRequiredData(article: article, settings: additionalSettings, commentId: commentId)

        _ = flowsSdkCoordinator.startCommentThreadFlow(conversationData: conversationData,
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
            let error: OWError = err as? OWError ?? OWError.commentThreadFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

#if BETA
    func testingPlayground(postId: OWPostId,
                           presentationalMode: OWPresentationalMode,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol? = nil,
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

        let testingPlaygroundData = OWTestingPlaygroundRequiredData(settings: additionalSettings)

        _ = flowsSdkCoordinator.startTestingPlaygroundFlow(testingPlaygroundData: testingPlaygroundData,
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
            let error: OWError = err as? OWError ?? OWError.missingImplementation
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }
#endif
}

// UIViews
extension OWUILayer {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion) {

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
                                                                settings: additionalSettings,
                                                                presentationalStyle: .none)

        _ = viewsSdkCoordinator.preConversationView(preConversationData: preConversationData,
                                                callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.preConversationView
            completion(.failure(error))
        })
    }

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion) {

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
                                                          settings: additionalSettings,
                                                          presentationalStyle: .none)

        _ = viewsSdkCoordinator.conversationView(conversationData: conversationData,
                                                callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.preConversationView
            completion(.failure(error))
        })
    }

#if BETA
    func testingPlayground(postId: OWPostId,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol?,
                           callbacks: OWViewActionsCallbacks?,
                           completion: @escaping OWViewCompletion) {

        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        let testingPlaygroundData = OWTestingPlaygroundRequiredData(settings: additionalSettings)

        _ = viewsSdkCoordinator.testingPlaygroundView(testingPlaygroundData: testingPlaygroundData,
                                                callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.missingImplementation
            completion(.failure(error))
        })
    }
#endif
}

fileprivate extension OWUILayer {
    func setPostId(postId: OWPostId, completion: @escaping OWDefaultCompletion) {
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

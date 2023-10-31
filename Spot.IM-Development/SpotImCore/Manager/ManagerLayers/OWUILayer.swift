//
//  OWUILayer.swift
//  SpotImCore
//
//  Created by Alon Haiut on 06/07/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWUILayer: OWUI, OWUIFlows, OWUIViews, OWRouteringModeProtocol, OWCompactRouteringCompatible, OWRouteringCompatible {
    var flows: OWUIFlows { return self }
    var views: OWUIViews { return self }
    var customizations: OWCustomizations { return self._customizations }
    var authenticationUI: OWUIAuthentication { return self._authenticationUI }

    lazy var activeRouteringMode: OWRouteringModeInternal = {
        return .routering(routering: routering)
    }()

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
    fileprivate let servicesProvider: OWSharedServicesProviding

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared,
         flowsSdkCoordinator: OWFlowsSDKCoordinator = OWFlowsSDKCoordinator(),
         viewsSdkCoordinator: OWViewsSDKCoordinator = OWViewsSDKCoordinator(),
         customizations: OWCustomizations = OWCustomizationsLayer(),
         authenticationUI: OWUIAuthentication = OWUIAuthenticationLayer()) {
        self.servicesProvider = servicesProvider
        self.flowsSdkCoordinator = flowsSdkCoordinator
        self.viewsSdkCoordinator = viewsSdkCoordinator
        self._customizations = customizations
        self._authenticationUI = authenticationUI
    }
}

// UIFlows
extension OWUILayer {
    func preConversation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWViewCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

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
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .partOfFlow)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: presentationalMode.style)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.preConversationFlow
            completion(.failure(error))
        })
        .disposed(by: flowDisposeBag)
    }

    func conversation(postId: OWPostId,
                      article: OWArticleProtocol,
                      presentationalMode: OWPresentationalMode,
                      additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                      callbacks: OWViewActionsCallbacks? = nil,
                      completion: @escaping OWDefaultCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

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
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .partOfFlow)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: presentationalMode.style)
        })
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

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         presentationalMode: OWPresentationalMode,
                         additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                         callbacks: OWViewActionsCallbacks? = nil,
                         completion: @escaping OWDefaultCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

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
        let commentCreationData = OWCommentCreationRequiredData(article: article,
                                                                settings: additionalSettings,
                                                                commentCreationType: .comment,
                                                                presentationalStyle: presentationalMode.style)

        _ = flowsSdkCoordinator.startCommentCreationFlow(conversationData: conversationData,
                                                    commentCreationData: commentCreationData,
                                                    presentationalMode: presentationalMode,
                                                    callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .partOfFlow)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: presentationalMode.style)
        })
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
        guard validateSpotIdExist(completion: completion) else { return }

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
        let commentThreadData = OWCommentThreadRequiredData(article: article,
                                                            settings: additionalSettings,
                                                            commentId: commentId,
                                                            presentationalStyle: presentationalMode.style)

        _ = flowsSdkCoordinator.startCommentThreadFlow(conversationData: conversationData,
                                                    commentThreadData: commentThreadData,
                                                    presentationalMode: presentationalMode,
                                                    callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .partOfFlow)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: presentationalMode.style)
        })
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
                           additionalSettings: OWTestingPlaygroundSettingsProtocol = OWTestingPlaygroundSettings(),
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
        .do(onNext: { [weak self] _ in
            self?.setActiveRouter(for: .partOfFlow)
        })
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

#if AUTOMATION
    func fonts(presentationalMode: OWPresentationalMode,
               additionalSettings: OWAutomationSettingsProtocol,
               callbacks: OWViewActionsCallbacks? = nil,
               completion: @escaping OWDefaultCompletion) {

        prepareForNewFlow()

        let automationData = OWAutomationRequiredData(settings: additionalSettings)

        _ = flowsSdkCoordinator.startFontsFlow(automationData: automationData,
                                                           presentationalMode: presentationalMode,
                                                           callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .do(onNext: { [weak self] _ in
            self?.setActiveRouter(for: .partOfFlow)
        })
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

    func userStatus(presentationalMode: OWPresentationalMode,
                    additionalSettings: OWAutomationSettingsProtocol,
                    callbacks: OWViewActionsCallbacks? = nil,
                    completion: @escaping OWDefaultCompletion) {

        prepareForNewFlow()

        let automationData = OWAutomationRequiredData(settings: additionalSettings)

        _ = flowsSdkCoordinator.startUserStatusFlow(automationData: automationData,
                                                           presentationalMode: presentationalMode,
                                                           callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .do(onNext: { [weak self] _ in
            self?.setActiveRouter(for: .partOfFlow)
        })
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
        guard validateSpotIdExist(completion: completion) else { return }

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
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .independent)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
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
        guard validateSpotIdExist(completion: completion) else { return }

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
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .independent)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.conversationView
            completion(.failure(error))
        })
    }

    func commentCreation(postId: OWPostId,
                         article: OWArticleProtocol,
                         commentCreationType: OWCommentCreationType,
                         additionalSettings: OWAdditionalSettingsProtocol,
                         callbacks: OWViewActionsCallbacks?,
                         completion: @escaping OWViewCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        let internalCommentCreationType: OWCommentCreationTypeInternal
        switch commentCreationType {
        case .comment:
            internalCommentCreationType = .comment
        case .edit(let commentId):
            // TODO - The comment might not be found in the service, we should fetch it somehow
            if let comment = servicesProvider.commentsService().get(commentId: commentId, postId: postId) {
                internalCommentCreationType = .edit(comment: comment)
            } else {
                completion(.failure(.commentCreationView))
                return
            }
        case .replyTo(let commentId):
            // TODO - The comment might not be found in the service, we should fetch it somehow
            if let comment = servicesProvider.commentsService().get(commentId: commentId, postId: postId) {
                internalCommentCreationType = .replyToComment(originComment: comment)
            } else {
                completion(.failure(.commentCreationView))
                return
            }
        }

        let commentCreationData = OWCommentCreationRequiredData(
            article: article,
            settings: additionalSettings,
            commentCreationType: internalCommentCreationType,
            presentationalStyle: .none
        )

        _ = viewsSdkCoordinator.commentCreationView(commentCreationData: commentCreationData,
                                                    callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.setActiveRouter(for: .independent)
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.commentCreationView
            completion(.failure(error))
        })
    }

    func commentThread(postId: OWPostId,
                       article: OWArticleProtocol,
                       commentId: OWCommentId,
                       additionalSettings: OWAdditionalSettingsProtocol,
                       callbacks: OWViewActionsCallbacks?,
                       completion: @escaping OWViewCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        setPostId(postId: postId) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        let commentThreadData = OWCommentThreadRequiredData(
            article: article,
            settings: additionalSettings,
            commentId: commentId,
            presentationalStyle: .none
        )

        _ = viewsSdkCoordinator.commentThreadView(commentThreadData: commentThreadData, callbacks: callbacks)
            .observe(on: MainScheduler.asyncInstance)
            .take(1)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.setActiveRouter(for: .independent)
                self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
            })
            .subscribe(onNext: { result in
                completion(.success(result.toShowable()))
            }, onError: { err in
                let error: OWError = err as? OWError ?? OWError.commentThreadView
                completion(.failure(error))
            })
    }

    func reportReason(postId: OWPostId,
                      commentId: OWCommentId,
                      parentId: OWCommentId,
                      additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                      callbacks: OWViewActionsCallbacks?,
                      completion: @escaping OWViewCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        checkIfPostIdExists { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        let reportReasonData = OWReportReasonsRequiredData(commentId: commentId,
                                                          parentId: parentId)

        _ = viewsSdkCoordinator.reportReasonView(reportData: reportReasonData,
                                                 callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.reportReasonView
            completion(.failure(error))
        })
    }

    func clarityDetails(postId: OWPostId,
                        commentId: OWCommentId,
                        type: OWClarityDetailsType,
                        additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                        callbacks: OWViewActionsCallbacks?,
                        completion: @escaping OWViewCompletion) {
        guard validateSpotIdExist(completion: completion) else { return }

        checkIfPostIdExists { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        _ = viewsSdkCoordinator.clarityDetailsView(type: type, callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.clarityDetailsView
            completion(.failure(error))
        })
    }

    func webTab(postId: OWPostId,
                tabOptions: OWWebTabOptions,
                additionalSettings: OWAdditionalSettingsProtocol = OWAdditionalSettings(),
                callbacks: OWViewActionsCallbacks?,
                completion: @escaping OWViewCompletion) {

        guard validateSpotIdExist(completion: completion) else { return }

        checkIfPostIdExists { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                return
            case .success(_):
                break
            }
        }

        _ = viewsSdkCoordinator.webTabView(tabOptions: tabOptions, callbacks: callbacks)
        .observe(on: MainScheduler.asyncInstance)
        .take(1)
        .do(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.sendStyleConfigureEvents(additionalSettings: additionalSettings, presentationalStyle: .none)
        })
        .subscribe(onNext: { result in
            completion(.success(result.toShowable()))
        }, onError: { err in
            let error: OWError = err as? OWError ?? OWError.webTabView
            completion(.failure(error))
        })
    }

#if BETA
    func testingPlayground(postId: OWPostId,
                           additionalSettings: OWTestingPlaygroundSettingsProtocol = OWTestingPlaygroundSettings(),
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
        .do(onNext: { [weak self] _ in
            self?.setActiveRouter(for: .independent)
        })
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
    func validateSpotIdExist<T: Any>(completion: @escaping (Result<T, OWError>) -> Void) -> Bool {
        let spotId = OpenWeb.manager.spotId
        guard !spotId.isEmpty else {
            completion(.failure(.missingSpotId))
            return false
        }

        return true
    }

    func setPostId(postId: OWPostId, completion: @escaping OWDefaultCompletion) {
        guard let manager = OpenWeb.manager as? OWManagerInternalProtocol else {
            let error = OWError.castingError(description: "OpenWeb.manager casting to OWManagerInternalProtocol failed")
            completion(.failure(error))
            return
        }

        manager.postId = postId
    }

    func checkIfPostIdExists(completion: @escaping OWDefaultCompletion) {
        guard OWManager.manager.postId != nil else {
            completion(.failure(OWError.missingPostId))
            return
        }
        completion(.success(()))
    }

    func prepareForNewFlow() {
        // Discard any previous subscription to other flows
        flowDisposeBag = DisposeBag()
    }

    func setActiveRouter(for viewableMode: OWViewableMode) {
        switch viewableMode {
        case .independent:
            activeRouteringMode = .compactRoutering(compactRoutering: self.compactRoutering)
        case .partOfFlow:
            activeRouteringMode = .routering(routering: self.routering)
        }
    }
}

fileprivate extension OWUILayer {
    func event(for eventType: OWAnalyticEventType, presentationalStyle: OWPresentationalModeCompact) -> OWAnalyticEvent {
        return servicesProvider
            .analyticsEventCreatorService()
            .analyticsEvent(
                for: eventType,
                articleUrl: "",
                layoutStyle: OWLayoutStyle(from: presentationalStyle),
                component: .none)
    }

    func sendEvent(for eventType: OWAnalyticEventType, presentationalStyle: OWPresentationalModeCompact) {
        let event = event(for: eventType, presentationalStyle: presentationalStyle)
        servicesProvider
            .analyticsService()
            .sendAnalyticEvents(events: [event])
    }

    func sendStyleConfigureEvents(additionalSettings: OWAdditionalSettingsProtocol, presentationalStyle: OWPresentationalModeCompact) {
        self.sendEvent(for: .configuredPreConversationStyle(style: additionalSettings.preConversationSettings.style), presentationalStyle: presentationalStyle)
        self.sendEvent(for: .configuredCommentCreationStyle(style: additionalSettings.commentCreationSettings.style), presentationalStyle: presentationalStyle)
        self.sendEvent(for: .configuredFullConversationStyle(style: additionalSettings.fullConversationSettings.style), presentationalStyle: presentationalStyle)
    }
}

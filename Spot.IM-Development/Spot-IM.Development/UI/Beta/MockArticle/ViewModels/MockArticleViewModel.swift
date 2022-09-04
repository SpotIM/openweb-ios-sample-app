//
//  MockArticleViewModel.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 04/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import SpotImCore

#if NEW_API

protocol MockArticleViewModelingInputs {
    var fullConversationButtonTapped: PublishSubject<Void> { get }
    var fullCommentCreationButtonTapped: PublishSubject<Void> { get }
}

protocol MockArticleViewModelingOutputs {
    var title: String { get }
    var showFullConversationButton: Observable<PresentationalModeCompact> { get }
    var showFullCommentCreationButton: Observable<PresentationalModeCompact> { get }
    var articleImageURL: Observable<URL> { get }
}

protocol MockArticleViewModeling {
    var inputs: MockArticleViewModelingInputs { get }
    var outputs: MockArticleViewModelingOutputs { get }
}

class MockArticleViewModel: MockArticleViewModeling, MockArticleViewModelingInputs, MockArticleViewModelingOutputs {
    var inputs: MockArticleViewModelingInputs { return self }
    var outputs: MockArticleViewModelingOutputs { return self }
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate let imageProviderAPI: ImageProviding
    
    fileprivate let _articleImageURL = BehaviorSubject<URL?>(value: nil)
    var articleImageURL: Observable<URL> {
        return _articleImageURL
            .unwrap()
            .asObservable()
    }
    
    fileprivate let _actionSettings = BehaviorSubject<SDKUIFlowActionSettings?>(value: nil)
    fileprivate var actionSettings: Observable<SDKUIFlowActionSettings> {
        return _actionSettings
            .unwrap()
            .asObservable()
    }
    
    let fullConversationButtonTapped = PublishSubject<Void>()
    var fullCommentCreationButtonTapped = PublishSubject<Void>()
    
    var showFullConversationButton: Observable<PresentationalModeCompact> {
        return actionSettings
            // Map here is also like a filter
            .map { settings in
                if case .fullConversation(let mode) = settings.actionType {
                    return mode
                } else {
                    return nil
                }
            }
            .unwrap()
            
    }
    
    var showFullCommentCreationButton: Observable<PresentationalModeCompact> {
        return actionSettings
            // Map here is also like a filter
            .map { settings in
                if case .commentCreation(let mode) = settings.actionType {
                    return mode
                } else {
                    return nil
                }
            }
            .unwrap()
    }
    
    lazy var title: String = {
        return NSLocalizedString("MockArticle", comment: "")
    }()
    
    init(imageProviderAPI: ImageProviding = ImageProvider(),
         actionSettings: SDKUIFlowActionSettings) {
        self.imageProviderAPI = imageProviderAPI
        _actionSettings.onNext(actionSettings)
        setupObservers()
    }
}

fileprivate extension MockArticleViewModel {
    func setupObservers() {
        let articleURL = imageProviderAPI.randomImageUrl()
        _articleImageURL.onNext(articleURL)
        
        fullConversationButtonTapped
            .subscribe(onNext: { _ in
                // TODO: Complete with the new SDK API
            })
            .disposed(by: disposeBag)

        fullCommentCreationButtonTapped
            .subscribe(onNext: { _ in
                // TODO: Complete with the new SDK API
            })
            .disposed(by: disposeBag)
    }
}

#endif

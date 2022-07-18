//
//  OWArticleHeaderViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 31/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWArticleHeaderViewModelingInputs {
    var tap: PublishSubject<Void> { get }
}

protocol OWArticleHeaderViewModelingOutputs {
    var conversationImageType: Observable<OWImageType> { get }
    var conversationTitle: Observable<String> { get }
    var conversationAuthor: Observable<String> { get }
    var headerTapped: Observable<Void> { get }
}

protocol OWArticleHeaderViewModeling {
    var inputs: OWArticleHeaderViewModelingInputs { get }
    var outputs: OWArticleHeaderViewModelingOutputs { get }
}

class OWArticleHeaderViewModel: OWArticleHeaderViewModeling,
                                OWArticleHeaderViewModelingInputs,
                                OWArticleHeaderViewModelingOutputs {
    
    var inputs: OWArticleHeaderViewModelingInputs { return self }
    var outputs: OWArticleHeaderViewModelingOutputs { return self }
    
    fileprivate let _articleMetadata = BehaviorSubject<SpotImArticleMetadata?>(value: nil)
        
    init (articleMetadata: SpotImArticleMetadata? = nil) {
        if let articleMetadata = articleMetadata {
            self._articleMetadata.onNext(articleMetadata)
        }
    }
    
    fileprivate lazy var articleMetadata: Observable<SpotImArticleMetadata> = {
        self._articleMetadata
            .unwrap()
    }()
    
    var tap = PublishSubject<Void>()
    
    var headerTapped: Observable<Void> {
        return tap.asObservable()
    }
    
    var conversationImageType: Observable<OWImageType> {
        self.articleMetadata
            .map {
                if let url = URL(string: $0.thumbnailUrl) {
                    return .custom(url: url)
                }
                return .defaultImage
            }
    }
    var conversationTitle: Observable<String> {
        self.articleMetadata
            .map { $0.title}
    }
    var conversationAuthor: Observable<String> {
        self.articleMetadata
            .map { $0.subtitle}
    }
}


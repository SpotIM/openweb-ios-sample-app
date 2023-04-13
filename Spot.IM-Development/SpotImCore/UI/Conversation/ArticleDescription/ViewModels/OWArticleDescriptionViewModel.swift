//
//  OWArticleDescriptionViewModel.swift
//  SpotImCore
//
//  Created by Revital Pisman on 30/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWArticleDescriptionViewModelingInputs {
    var tap: PublishSubject<Void> { get }
}

protocol OWArticleDescriptionViewModelingOutputs {
    var conversationImageType: Observable<OWImageType> { get }
    var conversationTitle: Observable<String> { get }
    var conversationAuthor: Observable<String> { get }
    var headerTapped: Observable<Void> { get }
}

protocol OWArticleDescriptionViewModeling {
    var inputs: OWArticleDescriptionViewModelingInputs { get }
    var outputs: OWArticleDescriptionViewModelingOutputs { get }
}

class OWArticleDescriptionViewModel: OWArticleDescriptionViewModeling,
                                     OWArticleDescriptionViewModelingInputs,
                                     OWArticleDescriptionViewModelingOutputs {
    var inputs: OWArticleDescriptionViewModelingInputs { return self }
    var outputs: OWArticleDescriptionViewModelingOutputs { return self }

    fileprivate let _article = BehaviorSubject<OWArticleProtocol?>(value: nil)
//    fileprivate let article: OWArticleProtocol

    fileprivate lazy var article: Observable<OWArticleProtocol> = {
        self._article
            .unwrap()
    }()

    init(article: OWArticleProtocol) {
        _article.onNext(article)
    }

    var tap = PublishSubject<Void>()

    var headerTapped: Observable<Void> {
        return tap.asObservable()
    }

    var conversationImageType: Observable<OWImageType> {
        self.article
            .map {
                if let url = $0.thumbnailUrl {
                    return .custom(url: url)
                }
                return .defaultImage
            }
    }

    var conversationTitle: Observable<String> {
        self.article
            .map { $0.title }
    }
    var conversationAuthor: Observable<String> {
        self.article
            .map { $0.subtitle }
            .unwrap()
            .map { $0.uppercased() }
    }
}

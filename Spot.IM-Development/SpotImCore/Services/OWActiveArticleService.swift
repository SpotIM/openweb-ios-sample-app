//
//  OWActiveArticleService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWActiveArticleServicing {
    var newArticle: Observable<OWArticleExtraData> { get }
    func triggerNewServerArticle(_ article: OWArticleExtraData)
    func updateStrategy(_ strategy: OWArticleInformationStrategy)
}

class OWActiveArticleService: OWActiveArticleServicing {

    fileprivate let _strategy = BehaviorSubject<OWArticleInformationStrategy>(value: .server)
    fileprivate let _newServerArticle = BehaviorSubject<OWArticleExtraData>(value: OWArticleExtraData())

    var newArticle: Observable<OWArticleExtraData> {
        return Observable.combineLatest(_newServerArticle, _strategy) { serverArticle, strategy in
            switch strategy {
            case .server:
                return serverArticle
            case .local(let data):
                return data
            }
        }
        .asObservable()
        .share(replay: 1)
    }

    func triggerNewServerArticle(_ article: OWArticleExtraData) {
        _newServerArticle.onNext(article)
    }

    func updateStrategy(_ strategy: OWArticleInformationStrategy) {
        _strategy.onNext(strategy)
    }
}

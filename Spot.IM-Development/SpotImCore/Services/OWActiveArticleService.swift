//
//  OWActiveArticleService.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import RxSwift

protocol OWActiveArticleServicing {
    var articleExtraData: Observable<OWArticleExtraData> { get }
    func updateStrategy(_ strategy: OWArticleInformationStrategy)
    func updatePost(_ post: OWPostId)
}

class OWActiveArticleService: OWActiveArticleServicing {

    fileprivate let _strategy = BehaviorSubject<OWArticleInformationStrategy>(value: .server)
    fileprivate let _serverArticle = BehaviorSubject<OWArticleExtraData>(value: OWArticleExtraData.empty)

    fileprivate unowned let servicesProvider: OWSharedServicesProviding
    fileprivate var disposeBag: DisposeBag

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()
        setupObservers()
    }

    fileprivate var newPost = PublishSubject<OWPostId>()

    var articleExtraData: Observable<OWArticleExtraData> {
        return Observable.combineLatest(_serverArticle, _strategy) { serverArticle, strategy in
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

    func updateStrategy(_ strategy: OWArticleInformationStrategy) {
        _strategy.onNext(strategy)
    }

    func updatePost(_ post: OWPostId) {
        _strategy.onNext(.server)
        _serverArticle.onNext(.empty)
        newPost.onNext(post)
    }
}

fileprivate extension OWActiveArticleService {
    func setupObservers() {
        newPost
            .withLatestFrom(_strategy) { _, strategy in
                return strategy
            }
            .filter {
                if case .server = $0 {
                    return true
                } else {
                    return false
                }
            }
            .flatMap { [weak self] _ -> Observable<Event<OWConversationReadRM>> in
                guard let self = self else { return .empty() }
                return self.servicesProvider
                    .netwokAPI()
                    .conversation
                    .conversationRead(mode: .default, page: .first)
                    .response
                    .exponentialRetry(maxAttempts: 3, millisecondsDelay: 1000)
                    .materialize()
            }
            .map { event -> OWConversationReadRM? in
                switch event {
                case .next(let conversation):
                    return conversation
                default:
                    return nil
                }
            }
            .unwrap()
            .subscribe(onNext: { [weak self] conversation in
                guard let self = self,
                      let extractData = conversation.extractData,
                      let url = extractData.url,
                      let title = extractData.title
                else { return }

                let articleExtraData = OWArticleExtraData(url: url, title: title, subtitle: extractData.description, thumbnailUrl: extractData.thumbnailUrl)
                self._serverArticle.onNext(articleExtraData)
            })
            .disposed(by: disposeBag)
    }
}

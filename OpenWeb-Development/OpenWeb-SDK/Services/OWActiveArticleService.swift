//
//  OWActiveArticleService.swift
//  OpenWebSDK
//
//  Created by  Nogah Melamed on 29/08/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import RxSwift

protocol OWActiveArticleServicing {
    var articleExtraData: Observable<OWArticleExtraData> { get }
    func updateStrategy(_ strategy: OWArticleInformationStrategy)
    func updatePost(_ post: OWPostId)
}

class OWActiveArticleService: OWActiveArticleServicing {

    private let _strategy = BehaviorSubject<OWArticleInformationStrategy>(value: .server)
    private let _serverArticle = BehaviorSubject<OWArticleExtraData>(value: OWArticleExtraData.empty)

    private unowned let servicesProvider: OWSharedServicesProviding
    private var disposeBag: DisposeBag

    init(servicesProvider: OWSharedServicesProviding) {
        self.servicesProvider = servicesProvider
        disposeBag = DisposeBag()
        setupObservers()
    }

    private var newPost = PublishSubject<OWPostId>()

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
        _serverArticle.onNext(.empty)
        newPost.onNext(post)
    }
}

private extension OWActiveArticleService {
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
                    .networkAPI()
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

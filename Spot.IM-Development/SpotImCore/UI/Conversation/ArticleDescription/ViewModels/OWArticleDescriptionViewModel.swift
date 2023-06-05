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
    var triggerCustomizeTitleLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeAuthorLabelUI: PublishSubject<UILabel> { get }
    var triggerCustomizeImageViewUI: PublishSubject<UIImageView> { get }
}

protocol OWArticleDescriptionViewModelingOutputs {
    var conversationImageType: Observable<OWImageType> { get }
    var conversationImage: Observable<UIImage> { get }
    var conversationTitle: Observable<String> { get }
    var conversationAuthor: Observable<String> { get }
    var headerTapped: Observable<Void> { get }
    var customizeTitleLabelUI: Observable<UILabel> { get }
    var customizeAuthorLabelUI: Observable<UILabel> { get }
    var customizeImageViewUI: Observable<UIImageView> { get }
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

    // Required to work with BehaviorSubject in the RX chain as the final subscriber begin after the initial publish subjects send their first elements
    fileprivate let _triggerCustomizeTitleLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeAuthorLabelUI = BehaviorSubject<UILabel?>(value: nil)
    fileprivate let _triggerCustomizeImageViewUI = BehaviorSubject<UIImageView?>(value: nil)

    var tap = PublishSubject<Void>()
    var triggerCustomizeTitleLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeAuthorLabelUI = PublishSubject<UILabel>()
    var triggerCustomizeImageViewUI = PublishSubject<UIImageView>()

    var customizeTitleLabelUI: Observable<UILabel> {
        return _triggerCustomizeTitleLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeAuthorLabelUI: Observable<UILabel> {
        return _triggerCustomizeAuthorLabelUI
            .unwrap()
            .asObservable()
    }

    var customizeImageViewUI: Observable<UIImageView> {
        return _triggerCustomizeImageViewUI
            .unwrap()
            .asObservable()
    }

    fileprivate let _article = BehaviorSubject<OWArticleProtocol?>(value: nil)
    fileprivate lazy var article: Observable<OWArticleProtocol> = {
        self._article
            .unwrap()
    }()

    var conversationImageType: Observable<OWImageType> {
        self.article
            .map {
                if let url = $0.thumbnailUrl {
                    return .custom(url: url)
                }
                return .defaultImage
            }
    }

    var conversationImage: Observable<UIImage> {
        return Observable.empty()
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

    var headerTapped: Observable<Void> {
        return tap.asObservable()
    }

    fileprivate let disposeBag = DisposeBag()

    init(article: OWArticleProtocol) {
        _article.onNext(article)
        setupObservers()
    }
}

fileprivate extension OWArticleDescriptionViewModel {
    func setupObservers() {
        triggerCustomizeTitleLabelUI
            .bind(to: _triggerCustomizeTitleLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeAuthorLabelUI
            .bind(to: _triggerCustomizeAuthorLabelUI)
            .disposed(by: disposeBag)

        triggerCustomizeImageViewUI
            .bind(to: _triggerCustomizeImageViewUI)
            .disposed(by: disposeBag)

        triggerCustomizeImageViewUI
            .flatMapLatest { [weak self] image -> Observable<UIImageView> in
                guard let self = self else { return .empty() }
                return self.conversationImage
                    .map { _ in return image }
            }
            .bind(to: _triggerCustomizeImageViewUI)
            .disposed(by: disposeBag)
    }
}

//
//  OWGifPreviewViewModel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 04/03/2024.
//  Copyright © 2024 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWGifPreviewViewModelingInputs {
    var gifUrl: PublishSubject<String?> { get }
    var removeButtonTap: PublishSubject<Void> { get }
}

protocol OWGifPreviewViewModelingOutputs {
    var gifUrlOutput: Observable<String?> { get }
    var removeButtonTapped: Observable<Void> { get }
}

protocol OWGifPreviewViewModeling {
    var inputs: OWGifPreviewViewModelingInputs { get }
    var outputs: OWGifPreviewViewModelingOutputs { get }
}

class OWGifPreviewViewModel: OWGifPreviewViewModeling,
                             OWGifPreviewViewModelingInputs,
                             OWGifPreviewViewModelingOutputs {

    var inputs: OWGifPreviewViewModelingInputs { return self }
    var outputs: OWGifPreviewViewModelingOutputs { return self }

    fileprivate let disposeBag = DisposeBag()
    fileprivate let servicesProvider: OWSharedServicesProviding

    var removeButtonTap: PublishSubject<Void> = PublishSubject()
    var gifUrl: PublishSubject<String?> = PublishSubject()

    var gifUrlOutput: Observable<String?> {
        gifUrl
            .asObservable()
            .startWith(nil)
    }

    var removeButtonTapped: Observable<Void> {
        removeButtonTap
            .asObservable()
    }

    init(servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.servicesProvider = servicesProvider

        setupObservers()
    }
}

fileprivate extension OWGifPreviewViewModel {
    func setupObservers() {
        removeButtonTap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.gifUrl.onNext(nil)
        })
        .disposed(by: disposeBag)
    }
}


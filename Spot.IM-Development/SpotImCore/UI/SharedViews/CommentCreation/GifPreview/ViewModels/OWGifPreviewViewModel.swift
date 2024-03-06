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
    var gifData: PublishSubject<OWCommentGif?> { get }
    var removeButtonTap: PublishSubject<Void> { get }
}

protocol OWGifPreviewViewModelingOutputs {
    var gifDataOutput: Observable<OWCommentGif?> { get }
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
    var gifData: PublishSubject<OWCommentGif?> = PublishSubject()

    var gifDataOutput: Observable<OWCommentGif?> {
        gifData
            .asObservable()
            .debug("NOGAH: gifDataOutput")
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
            self.gifData.onNext(nil)
        })
        .disposed(by: disposeBag)
    }
}


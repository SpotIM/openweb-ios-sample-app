//
//  OWFullScreenImageViewModel.swift
//  OpenWebSDK
//
//  Created by Refael Sommer on 14/12/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import RxSwift

protocol OWFullScreenImageViewModelingInputs { }

protocol OWFullScreenImageViewModelingOutputs {
    var image: Observable<UIImage> { get }
}

protocol OWFullScreenImageViewModeling {
    var inputs: OWFullScreenImageViewModelingInputs { get }
    var outputs: OWFullScreenImageViewModelingOutputs { get }
}

class OWFullScreenImageViewModel: OWFullScreenImageViewModeling, OWFullScreenImageViewModelingInputs, OWFullScreenImageViewModelingOutputs {
    var inputs: OWFullScreenImageViewModelingInputs { return self }
    var outputs: OWFullScreenImageViewModelingOutputs { return self }

    var disposeBag = DisposeBag()

    var _image = BehaviorSubject<UIImage?>(value: nil)
    var image: Observable<UIImage> {
        return _image
            .unwrap()
            .asObservable()
    }

    init(image: UIImage) {
        self._image.onNext(image)
    }
}

//
//  UILoggerViewModel.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 20/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol UILoggerViewModelingInputs {
    func log(text: String)
    func clear()
}

protocol UILoggerViewModelingOutputs {
    var loggerText: Observable<String> { get }
    var title: Observable<String> { get }
}

protocol UILoggerViewModeling {
    var inputs: UILoggerViewModelingInputs { get }
    var outputs: UILoggerViewModelingOutputs { get }
}

class UILoggerViewModel: UILoggerViewModeling, UILoggerViewModelingInputs, UILoggerViewModelingOutputs {
    var inputs: UILoggerViewModelingInputs { return self }
    var outputs: UILoggerViewModelingOutputs { return self }

    let _title = BehaviorSubject<String>(value: "")
    var title: Observable<String> {
        return _title
                .asObservable()
    }

    fileprivate let _loggerText = BehaviorSubject<String>(value: "")
    var loggerText: Observable<String> {
        return _loggerText
                .asObservable()
    }

    init(title: String = "") {
        self._title.onNext(title)
    }

    func log(text: String) {
        _ = _loggerText
            .take(1)
            .subscribe(onNext: { [weak self] lastText in
                guard let self = self else { return }
                self._loggerText.onNext(lastText + "\n" + text)
            })
    }

    func clear() {
        _loggerText.onNext("")
    }
}

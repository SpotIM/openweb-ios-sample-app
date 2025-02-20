//
//  UILoggerViewModel.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 20/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import Combine

protocol UILoggerViewModelingInputs {
    func log(text: String)
    func clear()
}

protocol UILoggerViewModelingOutputs {
    var loggerText: AnyPublisher<String, Never> { get }
    var title: AnyPublisher<String, Never> { get }
}

protocol UILoggerViewModeling {
    var inputs: UILoggerViewModelingInputs { get }
    var outputs: UILoggerViewModelingOutputs { get }
}

class UILoggerViewModel: UILoggerViewModeling, UILoggerViewModelingInputs, UILoggerViewModelingOutputs {
    var inputs: UILoggerViewModelingInputs { return self }
    var outputs: UILoggerViewModelingOutputs { return self }

    let _title = CurrentValueSubject<String, Never>(value: "")
    var title: AnyPublisher<String, Never> {
        return _title
                .eraseToAnyPublisher()
    }

    private let _loggerText = CurrentValueSubject<String, Never>(value: "")
    var loggerText: AnyPublisher<String, Never> {
        return _loggerText
                .eraseToAnyPublisher()
    }

    init(title: String = "") {
        self._title.send(title)
    }

    func log(text: String) {
        _ = _loggerText
            .prefix(1)
            .sink(receiveValue: { [weak self] lastText in
                guard let self else { return }
                self._loggerText.send(lastText + "\n" + text)
            })
    }

    func clear() {
        _loggerText.send("")
    }
}

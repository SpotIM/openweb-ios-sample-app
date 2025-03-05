//
//  Combine+Helpers.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import Combine

extension Publisher {
    func voidify() -> AnyPublisher<Void, Failure> {
        map { _ in }
            .eraseToAnyPublisher()
    }

    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {
        compactMap { $0 }
            .eraseToAnyPublisher()
    }

    static func just(_ value: Output) -> AnyPublisher<Output, Failure> {
        Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }
}

 extension CurrentValueSubject where Failure == Never {
    convenience init(value: Output) {
        self.init(value)
    }
 }

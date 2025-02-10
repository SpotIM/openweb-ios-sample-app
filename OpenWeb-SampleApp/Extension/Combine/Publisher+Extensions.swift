//
//  Publisher+Extensions.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import Combine

extension Publisher {
    func voidify() -> AnyPublisher<Void, Never> {
        map { _ in }
            .catch { _ in Empty() }
            .eraseToAnyPublisher()
    }

    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {
        compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

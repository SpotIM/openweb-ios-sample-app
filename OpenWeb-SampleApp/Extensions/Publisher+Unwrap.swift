//
//  Publisher+Unwrap.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import Combine

extension Publisher {
    /// Unwraps optional elements, similar to RxSwift's unwrap()
    /// - Returns: A publisher of non-optional elements
    func unwrap<T>() -> AnyPublisher<T, Failure> where Output == T? {
        compactMap { $0 }
            .eraseToAnyPublisher()
    }
}

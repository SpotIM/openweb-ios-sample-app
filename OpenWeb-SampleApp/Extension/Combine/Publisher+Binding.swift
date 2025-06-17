//
//  Publisher+Binding.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import Combine

extension Publisher {
    /// Binds the publisher's output to a subject, similar to RxSwift's `bind(to:)`
    func bind<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Output, S.Failure == Failure {
        subscribe(subject)
    }

    /// Binds the publisher's output to a subscriber, similar to `RxSwift's bind(to:)`
    func bind<S: Subscriber>(to subscriber: S) -> AnyCancellable
    where S.Input == Self.Output, S.Failure == Self.Failure {
        sink(
            receiveCompletion: { completion in
                subscriber.receive(completion: completion)
            },
            receiveValue: { value in
                _ = subscriber.receive(value)
            }
        )
    }
}

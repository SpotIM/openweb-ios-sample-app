//
//  Publisher+Binding.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//

import Combine

extension Publisher {
    /// Binds the publisher's output to a subject, similar to RxSwift's bind(to:)
    /// - Parameter subject: The subject to bind to
    /// - Returns: A cancellable binding
    func bind<S: Subject>(to subject: S) -> AnyCancellable where S.Output == Output, S.Failure == Failure {
        sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    subject.send(completion: .failure(error))
                }
            },
            receiveValue: { value in
                subject.send(value)
            }
        )
    }

    /// Binds the publisher's output to a CurrentValueSubject, similar to RxSwift's bind(to:)
    /// - Parameter subject: The CurrentValueSubject to bind to
    /// - Returns: A cancellable binding
    func bind(to subject: CurrentValueSubject<Output, Failure>) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    subject.send(completion: .failure(error))
                }
            },
            receiveValue: { value in
                subject.value = value
            }
        )
    }

    /// Binds the publisher's output to a PassthroughSubject, similar to RxSwift's bind(to:)
    /// - Parameter subject: The PassthroughSubject to bind to
    /// - Returns: A cancellable binding
    func bind(to subject: PassthroughSubject<Output, Failure>) -> AnyCancellable {
        sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    subject.send(completion: .failure(error))
                }
            },
            receiveValue: { value in
                subject.send(value)
            }
        )
    }
}

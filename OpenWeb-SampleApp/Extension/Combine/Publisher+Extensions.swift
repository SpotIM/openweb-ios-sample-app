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

    /// Creates a Combine publisher similar to RxSwift's Observable.create()
    static func create<Output, Failure: Error>(
        subscribe: @escaping (PublisherObserver<Output, Failure>) -> Void
    ) -> AnyPublisher<Output, Failure> {
        return Deferred {
            Future<Output, Failure> { promise in
                let observer = PublisherObserver<Output, Failure>(
                    onNext: { value in
                        promise(.success(value))
                    },
                    onError: { error in
                        promise(.failure(error))
                    },
                    onCompleted: {
                        // Do nothing on completion, let the publisher complete naturally
                    }
                )

                subscribe(observer)
            }
        }.eraseToAnyPublisher()
    }
}

/// An observer class similar to RxSwift's `ObserverType`
struct PublisherObserver<Output, Failure: Error> {
    let onNext: (Output) -> Void
    let onError: (Failure) -> Void
    let onCompleted: () -> Void

    init(
        onNext: @escaping (Output) -> Void,
        onError: @escaping (Failure) -> Void,
        onCompleted: @escaping () -> Void
    ) {
        self.onNext = onNext
        self.onError = onError
        self.onCompleted = onCompleted
    }
}

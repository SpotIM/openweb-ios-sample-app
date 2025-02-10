//
//  RxSwift+Combine.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//  Copyright © 2025 OpenWeb. All rights reserved.
//

// TODO: Remove this file when we remove RxSwift from the project.

import Combine
import RxSwift

extension Publisher {
    /// Converts a Combine Publisher to an RxSwift Observable
    func asObservable() -> Observable<Output> {
        return Observable.create { observer in
            let cancellable = self.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                },
                receiveValue: { value in
                    observer.onNext(value)
                }
            )

            return Disposables.create {
                cancellable.cancel()
            }
        }
    }
}

extension ObservableType {
    /// Binds Rx Observable to a Combine Subscriber.
    func bind<S: Subscriber>(to subscriber: S) -> Disposable
    where S.Input == Element, S.Failure == Never {
        let subscription = RxToCombineSubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)
        let disposable = self.subscribe(
            onNext: { element in
                subscription.receive(element)
            },
            onError: { _ in
                // Treat Rx errors as .finished, ignoring the actual error.
                subscription.receiveCompletion(.finished)
            },
            onCompleted: {
                subscription.receiveCompletion(.finished)
            }
        )
        subscription.setDisposable(disposable)
        return subscription
    }
}

/// A Combine Subscription that wraps an RxSwift Disposable.
/// Holds a reference to the Combine Subscriber so we can forward events.
private class RxToCombineSubscription<S: Subscriber>: Subscription, Disposable {
    private var subscriber: S?
    private var disposable: Disposable?

    init(subscriber: S) {
        self.subscriber = subscriber
    }

    // MARK: - Subscription conformance

    func request(_ demand: Subscribers.Demand) {
        // no-op: Rx will push events regardless of demand
    }

    func cancel() {
        dispose()
    }

    // MARK: - Disposable conformance

    func dispose() {
        disposable?.dispose()
        disposable = nil
        subscriber = nil
    }

    // MARK: - Helpers

    /// Store the RxSwift Disposable so we can dispose it when the subscription is canceled.
    func setDisposable(_ disposable: Disposable) {
        self.disposable = disposable
    }

    /// Forward a value to the subscriber.
    func receive(_ input: S.Input) {
        _ = subscriber?.receive(input)
    }

    /// Forward a completion event to the subscriber.
    func receiveCompletion(_ completion: Subscribers.Completion<S.Failure>) {
        subscriber?.receive(completion: completion)
        subscriber = nil // so we don’t accidentally send more events.
    }
}

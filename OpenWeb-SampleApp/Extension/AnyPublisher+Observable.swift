//
//  AnyPublisher+Observable.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 04/02/2025.
//  Copyright 2025 OpenWeb. All rights reserved.
//

import RxSwift
import Combine

extension AnyPublisher {
    /// Converts a Combine AnyPublisher to an RxSwift Observable
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

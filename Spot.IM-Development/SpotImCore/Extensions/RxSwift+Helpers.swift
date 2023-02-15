//
//  RxSwift+Helpers.swift
//  SpotImCore
//
//  Created by Alon Haiut on 19/12/2021.
//  Copyright © 2021 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func voidify() -> Observable<Void> {
        return self.map { _ in }
    }

    func unwrap<T>() -> Observable<T> where Element == T? {
        return self
            .filter { $0 != nil }
            .map { $0! }
    }
}

extension ObserverType where Element == Void {
    func onNext() {
        self.onNext(())
    }
}

extension ObservableType {
    // Simple retry
    func retry(maxAttempts: Int, millisecondsDelay: Int, scheduler: SchedulerType = MainScheduler.instance) -> Observable<Self.Element> {
        return self.retry { errors in
            return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                if index < maxAttempts {
                    return Observable<Int64>.timer(RxTimeInterval.milliseconds(millisecondsDelay), scheduler: scheduler)
                } else {
                    return Observable.error(error)
                }
            }
        }
    }

    // Exponential retry (simple algorithm)
    func exponentialRetry(maxAttempts: Int, millisecondsDelay: Int, scheduler: SchedulerType = MainScheduler.instance) -> Observable<Self.Element> {
        return self.retry { errors in
            return errors.enumerated().flatMap { (index, error) -> Observable<Int64> in
                if index < maxAttempts {
                    let factor = index + 1
                    let exponential = factor * factor
                    let exponentialDelay =  RxTimeInterval.milliseconds(exponential * millisecondsDelay)
                    return Observable<Int64>.timer(exponentialDelay, scheduler: scheduler)
                } else {
                    return Observable.error(error)
                }
            }
        }
    }
}

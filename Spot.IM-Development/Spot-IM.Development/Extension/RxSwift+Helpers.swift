//
//  RxSwift+Helpers.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 10/05/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

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

//
//  OWUserDefaultsRxHelper.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 05/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol OWRawableKey<T> {
    associatedtype T
    var rawValue: String { get }
}

class OWRxHelperKey<T: Codable>: OWRawableKey {
    var rawValue: String

    init<T>(key: any OWRawableKey<T>) {
        self.rawValue = key.rawValue
    }
}

protocol OWPersistenceRxHelperProtocol {
    func observable<T>(key: OWRxHelperKey<T>, value: Data?, defaultValue: T?) -> Observable<T>
    func binder<T>(key: OWRxHelperKey<T>, binderBlock: @escaping (_ value: T) -> Void) -> Binder<T>
    func onNext<T>(key: OWRxHelperKey<T>, data: Data?)
}

class OWPersistenceRxHelper: OWPersistenceRxHelperProtocol {
    class OWRxHelperModel {
        var subscribableObservable: BehaviorSubject<Data?>?
        var binderObservable: Observable<Data?>?
    }

    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    fileprivate var rxObjects: [String: OWRxHelperModel] = [:]

    init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.encoder = encoder
    }

    func observable<T>(key: OWRxHelperKey<T>, value: Data?, defaultValue: T? = nil) -> Observable<T> {
        var defaultValueData: Data? = nil
        if value == nil,
           let defaultValue = defaultValue,
           let encodedData = try? encoder.encode(defaultValue) {
            defaultValueData = encodedData
        }

        let subscribable = rxObjects[key.rawValue]?.subscribableObservable ?? BehaviorSubject<Data?>(value: value ?? defaultValueData)
        addSubscribableIfNeeded(key: key, subscribable: subscribable)
        return subscribable
            .unwrap()
            .map { guard let value = try? JSONDecoder().decode(T.self, from: $0) else { return nil }
                return value
            }
            .unwrap()
            .share(replay: 1)
    }

    func binder<T>(key: OWRxHelperKey<T>, binderBlock: @escaping (_ value: T) -> Void) -> Binder<T> {
        return Binder(getBinderObservable(key: key)) { _, value in
            binderBlock(value)
        }
    }

    func onNext<T>(key: OWRxHelperKey<T>, data: Data?) {
        rxObjects[key.rawValue]?
            .subscribableObservable?
            .onNext(data)
    }
}

fileprivate extension OWPersistenceRxHelper {
    func getBinderObservable<T>(key: OWRxHelperKey<T>) -> Observable<Data?> {
        guard let observer = rxObject(key: key).binderObservable else {
            let observer = Observable<Data?>.create { _ in
                return Disposables.create()
            }
            .share(replay: 0)

            rxObject(key: key).binderObservable = observer

            return observer
        }

        return observer
    }

    func addSubscribableIfNeeded<T>(key: OWRxHelperKey<T>, subscribable: BehaviorSubject<Data?>) {
        if rxObject(key: key).subscribableObservable == nil {
            rxObject(key: key).subscribableObservable = subscribable
        }
    }

    func rxObject<T>(key: OWRxHelperKey<T>) -> OWRxHelperModel {
        let rxObject = rxObjects[key.rawValue] ?? OWRxHelperModel()
        if rxObjects[key.rawValue] == nil {
            rxObjects[key.rawValue] = rxObject
        }
        return rxObject
    }
}

//
//  UserDefaultsProviderRxHelper.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 05/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol UserDefaultsProviderRxHelperProtocol {
    func observable<T>(key: UserDefaultsProvider.UDKey<T>, value: Data?, defaultValue: T?) -> Observable<T>
    func binder<T>(key: UserDefaultsProvider.UDKey<T>, binderBlock: @escaping (_ value: T) -> Void) -> Binder<T>
    func onNext<T>(key: UserDefaultsProvider.UDKey<T>, data: Data?)
}

class UserDefaultsProviderRxHelper: UserDefaultsProviderRxHelperProtocol {
    class RxHelperModel {
        var subscribableObservable: BehaviorSubject<Data?>?
        var binderObservable: Observable<Data?>?
    }
    
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    fileprivate var rxObjects: [String: RxHelperModel] = [:]
    
    init(decoder: JSONDecoder, encoder: JSONEncoder) {
        self.decoder = decoder
        self.encoder = encoder
    }
    
    func observable<T>(key: UserDefaultsProvider.UDKey<T>, value: Data?, defaultValue: T? = nil) -> Observable<T> {
        var defaultValueData: Data? = nil
        if value == nil,
           let defaultValue = defaultValue,
           let encodedData = try? encoder.encode(defaultValue)
        {
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
    
    func binder<T>(key: UserDefaultsProvider.UDKey<T>, binderBlock: @escaping (_ value: T) -> Void) -> Binder<T> {
        return Binder(getBinderObservable(key: key)) { observer, value in
            binderBlock(value)
        }
    }
    
    func onNext<T>(key: UserDefaultsProvider.UDKey<T>, data: Data?) {
        rxObjects[key.rawValue]?
            .subscribableObservable?
            .onNext(data)
    }
}

fileprivate extension UserDefaultsProviderRxHelper {
    func getBinderObservable<T>(key: UserDefaultsProvider.UDKey<T>) -> Observable<Data?> {
        guard let observer = rxObject(key: key).binderObservable else {
            let observer = Observable<Data?>.create { observer in
                return Disposables.create()
            }
            .share(replay: 0)
            
            rxObject(key: key).binderObservable = observer
            
            return observer
        }
        return observer
    }
    
    func addSubscribableIfNeeded<T>(key: UserDefaultsProvider.UDKey<T>, subscribable: BehaviorSubject<Data?>) {
        if rxObject(key: key).subscribableObservable == nil {
            rxObject(key: key).subscribableObservable = subscribable
        }
    }
    
    func rxObject<T>(key: UserDefaultsProvider.UDKey<T>) -> RxHelperModel {
        let rxObject = rxObjects[key.rawValue] ?? RxHelperModel()
        if rxObjects[key.rawValue] == nil {
            rxObjects[key.rawValue] = rxObject
        }
        return rxObject
    }
}

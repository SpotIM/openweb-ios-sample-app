//
//  OWCacheService.swift
//  SpotImCore
//
//  Created by Alon Haiut on 07/03/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

/*
The cache service is currently store the data only in runtime, in the future we can add persistence as well.
By defualt each new value exist in the cache for 1 day. Of course this can be changed or dismissed completely
 
Examples of using this service:
 let cacheImages = OWCacheService<String, UIImage>()
 let cacheComments = OWCacheService<String, SPComment>(maxEntryCount: 20)
 let cacheUsers = OWCacheService<Int, SPUser>(expirationStrategy: .none)  // Notice the key can be any Hashable
*/


// Defaults
fileprivate struct DefaultMetrics {
    static let defaultEntryLifetime: TimeInterval = 24 * 60 * 60 // 1 day
    static let defaultMaxEntryCount: Int = 50
}

// Expiration options
enum OWCacheExpirationStrategy {
    case none
    case time(lifetime: TimeInterval) // `lifetime` parameter in seconds
}

class OWCacheService<Key: Hashable, Value: Any> {
    fileprivate let cache = NSCache<OWWrappedKey, OWWrappedValue>()
    fileprivate let expirationStrategy: OWCacheExpirationStrategy
    fileprivate let dateProvider: () -> Date
    
    init(dateProvider: @escaping () -> Date = Date.init,
         expirationStrategy: OWCacheExpirationStrategy = .time(lifetime: DefaultMetrics.defaultEntryLifetime),
         maxEntryCount: Int = DefaultMetrics.defaultMaxEntryCount) {
        self.dateProvider = dateProvider
        self.expirationStrategy = expirationStrategy
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let valueExpirationStrategy: OWWrappedValueExpirationStrategy
        switch expirationStrategy {
        case .none:
            valueExpirationStrategy = .none
        case .time(let lifetime):
            let dateThreshold = dateProvider().addingTimeInterval(lifetime)
            valueExpirationStrategy = .expiration(date: dateThreshold)
        }
        
        let wrappedValue = OWWrappedValue(value: value, expiration: valueExpirationStrategy)
        cache.setObject(wrappedValue, forKey: OWWrappedKey(key))
    }
    
    func value(forKey key: Key) -> Value? {
        guard let wrappedValue = cache.object(forKey: OWWrappedKey(key)) else {
            return nil
        }
        
        switch expirationStrategy {
        case .none:
            break;
        case .time(_):
            guard case .expiration(let date) = wrappedValue.expiration,
                  dateProvider() < date else {
                      // Such case means that the current date is after the expiration date
                      // Remove value that was expired and return nil
                      remove(forKey: key)
                      return nil
                  }
        }
        
        return wrappedValue.value
    }
    
    func remove(forKey key: Key) {
        cache.removeObject(forKey: OWWrappedKey(key))
    }
}

// Subscript for easy access
extension OWCacheService {
    subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript, we will remove any value for that key
                remove(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}


// OWWrappedKey - Key for NSCache must be from NSObject, that's why we use WrappedKey
fileprivate extension OWCacheService {
    class OWWrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
        override var hash: Int {
            return key.hashValue
        }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? OWWrappedKey else {
                return false
            }
            return value.key == key
        }
    }
}

// OWWrappedValue - We wrapped the value so we can add expiration strategy
fileprivate extension OWCacheService {
    class OWWrappedValue {
        let value: Value
        let expiration: OWWrappedValueExpirationStrategy
        
        init(value: Value, expiration: OWWrappedValueExpirationStrategy) {
            self.value = value
            self.expiration = expiration
        }
    }
}

fileprivate enum OWWrappedValueExpirationStrategy {
    case none
    case expiration(date: Date)
}


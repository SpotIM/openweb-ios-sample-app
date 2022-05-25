//
//  DecodableParser.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

final class OWDecodableParser<T: Decodable>: OWKeyPathParser, OWResponseParser {
    
    typealias Representation = T
    
    let decoder: JSONDecoder
    fileprivate let servicesProvider: OWSharedServicesProviding
    
    init(keyPath: String? = nil, decoder: JSONDecoder = defaultDecoder,
         servicesProvider: OWSharedServicesProviding = OWSharedServicesProvider.shared) {
        self.decoder = decoder
        self.servicesProvider = servicesProvider
        super.init(keyPath: keyPath)
    }
    
    func parse(data: Data) -> OWResult<Representation> {
        do {
            let item = try decoder.decode(Representation.self, from: data)
            return .success(item)
        } catch let error {
            servicesProvider.logger().log(level: .error, error.localizedDescription)
            return .failure(error)
        }
    }
    
    func parse(object: Any) -> OWResult<Representation> {
        do {
            let value = try valueForKeyPath(in: object)
            let data = try JSONSerialization.data(withJSONObject: value)
            let decoded = try decoder.decode(Representation.self, from: data)
            return .success(decoded)
        } catch let error {
            servicesProvider.logger().log(level: .error, error.localizedDescription)
            return .failure(error)
        }
    }
    
}

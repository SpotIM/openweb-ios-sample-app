//
//  DecodableParser.swift
//  SpotImCore
//
//  Created by Eugene on 08.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

final class DecodableParser<T: Decodable>: KeyPathParser, ResponseParser {
    
    typealias Representation = T
    
    let decoder: JSONDecoder
    
    init(keyPath: String? = nil, decoder: JSONDecoder = defaultDecoder) {
        self.decoder = decoder

        super.init(keyPath: keyPath)
    }
    
    func parse(data: Data) -> Result<Representation> {
        do {
            let item = try decoder.decode(Representation.self, from: data)
            return .success(item)
        } catch let error {
            Logger.error(error)
            
            return .failure(error)
        }
    }
    
    func parse(object: Any) -> Result<Representation> {
        do {
            let value = try valueForKeyPath(in: object)
            let data = try JSONSerialization.data(withJSONObject: value)
            let decoded = try decoder.decode(Representation.self, from: data)
            return .success(decoded)
        } catch let error {
            Logger.error(error)
            return .failure(error)
        }
    }
    
}

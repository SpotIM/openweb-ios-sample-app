//
//  JSONDecoder+SPExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 20/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

internal extension JSONDecoder {
    
    func decodeResponse<T: Decodable>(from response: DataResponse<Data, AFError>) -> OWResult<T> {
        guard response.error == nil else {
            return .failure(response.error!)
        }

        guard let responseData = response.data else {
            return .failure(SPNetworkError.emptyResponse)
        }

        do {
            let item = try decode(T.self, from: responseData)
            return .success(item)
        } catch {
            // error trying to decode response
            return .failure(error)
        }
    }
    
    func decodeResponseOptional<T: Decodable>(from data: Data) -> T? {
        let item = try? decode(T.self, from: data)
        return item
    }
    
}

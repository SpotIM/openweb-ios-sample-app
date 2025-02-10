//
//  Data+Extensions.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 10/02/2025.
//

import Foundation

extension Data {
    init?<T: Encodable>(encoding: T) {
        do {
            self = try JSONEncoder().encode(encoding)
        } catch {
            DLog("Error encoding data from \(T.self): \(error)")
            return nil
        }
    }

    func asType<T: Decodable>(_ type: T.Type) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: self)
        } catch {
            DLog("Error decoding data for \(T.self): \(error)")
            return nil
        }
    }
}

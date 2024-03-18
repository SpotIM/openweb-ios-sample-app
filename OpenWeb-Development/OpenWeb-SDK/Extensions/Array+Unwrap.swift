//
//  Array+Unwrap.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 19/12/2021.
//  Copyright © 2021 OpenWeb. All rights reserved.
//

import Foundation

extension Array {
    func unwrap<T>() -> [T] where Element == T? {
        return filter { $0 != nil }
            .map { $0! }
    }
}


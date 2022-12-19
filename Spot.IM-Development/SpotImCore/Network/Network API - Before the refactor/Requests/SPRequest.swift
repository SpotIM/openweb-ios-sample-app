//
//  SPRequest.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal protocol SPRequest {
    var method: HTTPMethod { get }
    var pathString: String { get }
    var url: URL! { get }
}

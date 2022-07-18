//
//  OWRealtimeEndpoint.swift
//  SpotImCore
//
//  Created by Alon Haiut on 29/06/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

enum OWRealtimeEndpoint: OWEndpoint {
    case fetchData(postId: OWPostId)
    
    // MARK: - HTTPMethod
    var method: HTTPMethod {
        switch self {
        case .fetchData:
            return .post
        }
    }
    
    // MARK: - Path
    var path: String {
        switch self {
        case .fetchData:
            return "/conversation/realtime/read"
        }
    }
    
    // MARK: - Parameters
    var parameters: Parameters? {
        switch self {
        // TODO: Complete parameters for the fetch data
        case .fetchData:
            return nil
        }
    }
}

protocol OWRealtimeAPI {
    func fetchData(postId: OWPostId) -> OWNetworkResponse<RealTimeModel>
}

extension OWNetworkAPI: OWRealtimeAPI {
    // Access by .realtime for readability
    var realtime: OWRealtimeAPI { return self }
    
    func fetchData(postId: OWPostId) -> OWNetworkResponse<RealTimeModel> {
        let endpoint = OWRealtimeEndpoint.fetchData(postId: postId)
        let requestConfigure = request(for: endpoint)
        return performRequest(route: requestConfigure)
    }
}

//
//  DemoAuthenticationProvider.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import Alamofire

internal class DemoUserAuthentication {
    
    /*
     Using a mock sso server for the demo login which is valid in our demo spot `sp_eCIlROSD`.
     Base URL defined as it is in `demo-publisher` github repository.
     The actual server responses arriving and implemented in sso-mock-server github repository.
     */
    
    fileprivate struct Metrics {
        static let baseUrlPath = "https://api.spot.im/sso-mock-server"
        static let loginURLPath = "\(baseUrlPath)/api/login"
        static let codeBURLPath = "\(baseUrlPath)/api/spotim-sso"
    }
    
    internal static func logIn(with username: String,
                               password: String,
                               completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        guard let url = URL(string: Metrics.loginURLPath) else { return }
        
        let params = ["username": username,
                      "password": password]
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: nil)
        .validate()
        .responseJSON { (response) in
            switch response.result {
            case .success(let json):
                let dict = json as? NSDictionary
                let token = dict?["token"] as? String
                completion(token, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    internal static func getCodeB(with codeA: String?,
                                  accessToken: String?,
                                  username: String?,
                                  accessTokenNetwork: String?,
                                  completion: @escaping (_ authCode: String?, _ error: Error?) -> Void) {
        guard let url = URL(string: Metrics.codeBURLPath) else { return }
        
        let params: Parameters = ["code_a": codeA ?? "",
                                  "access_token": accessToken ?? "",
                                  "username": username ?? "",
                                  "environment": "production"]
        
        let headers: HTTPHeaders = ["access-token-network": accessTokenNetwork ?? ""]
        
        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let json):
                let dict = json as? NSDictionary
                let codeB = dict?["code_b"] as? String
                completion(codeB, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

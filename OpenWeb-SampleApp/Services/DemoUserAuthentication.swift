//
//  DemoAuthenticationProvider.swift
//  OpenWeb-Development
//
//  Created by Andriy Fedin on 25/07/19.
//  Copyright © 2019 OpenWeb. All rights reserved.
//

import Foundation
import Alamofire
import OpenWebSDK

internal class DemoUserAuthentication {

    /*
     Using a mock sso server for the demo login which is valid in our demo spots.
     Base URL defined as it is in `demo-publisher` github repository.
     The actual server responses arriving and implemented in `sso-mock-server` github repository.
     */

    private struct Metrics {
        static let baseUrlPath = "https://api.spot.im/sso-mock-server"
        static let loginURLPath = "\(baseUrlPath)/api/login"
        static let codeBURLPath = "\(baseUrlPath)/api/spotim-sso"

        #if BETA
        static let baseUrlPathStaging = "https://dev.staging-spot.im/proxy/staging-v2/sso-mock-server/9292"
        static func loginURLPath(env: OWNetworkEnvironmentType) -> String {
            switch env {
            case .production:
                return "\(baseUrlPath)/api/login"
            case .staging:
                return "\(baseUrlPathStaging)/api/login"
            default:
                return "\(baseUrlPath)/api/login"
            }
        }
        static func codeBURLPath(env: OWNetworkEnvironmentType) -> String {
            switch env {
            case .production:
                return "\(baseUrlPath)/api/spotim-sso"
            case .staging:
                return "\(baseUrlPathStaging)/api/spotim-sso"
            default:
                return "\(baseUrlPath)/api/spotim-sso"
            }
        }
        #endif
    }

    internal static func logIn(with username: String,
                               password: String,
                               completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        var urlString = Metrics.loginURLPath
        #if BETA
        let env = OpenWeb.manager.environment
        urlString = Metrics.loginURLPath(env: env)
        #endif
        guard let url = URL(string: urlString) else { return }

        let params = ["username": username,
                      "password": password]

        struct Response: Codable {
            var token: String
        }

        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: nil)
        .validate()
        .responseDecodable { (data: DataResponse<Response, AFError>) in
            switch data.result {
            case .success(let response):
                completion(response.token, nil)
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
        var urlString = Metrics.codeBURLPath
        var environment = "production"
        #if BETA
        let env = OpenWeb.manager.environment
        urlString = Metrics.codeBURLPath(env: env)
        environment = env == .staging ? "staging" : "production"
        #endif
        guard let url = URL(string: urlString) else { return }

        let params: Parameters = ["code_a": codeA ?? "",
                                  "access_token": accessToken ?? "",
                                  "username": username ?? "",
                                  "env": environment]

        let headers: HTTPHeaders = ["access-token-network": accessTokenNetwork ?? ""]

        struct Response: Codable {
            var codeB: String

            // swiftlint:disable nesting
            enum CodingKeys: String, CodingKey {
                case codeB = "code_b"
            }
        }

        AF.request(url,
                   method: .post,
                   parameters: params,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .responseDecodable { (data: DataResponse<Response, AFError>) in
            switch data.result {
            case .success(let response):
                completion(response.codeB, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

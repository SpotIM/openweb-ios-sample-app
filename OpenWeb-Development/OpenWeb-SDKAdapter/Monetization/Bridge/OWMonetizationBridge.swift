//
//  OWMonetizationBridge.swift
//  OpenWeb-Development
//
//  Created by Anael on 04/12/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit

#if canImport(OpenWebIAUSDK)
@_exported import OpenWebIAUSDK
#endif

public protocol OWMonetizationBridgeProtocol {
    func getAd(postId: String,
               tmsServerIndex: Int,
               completion: @escaping (Result<UIView, Error>) -> Void)
}

public class OWMonetizationBridge: OWMonetizationBridgeProtocol {
    public init() {}
    
    public func getAd(postId: String,
                      tmsServerIndex: Int,
                      completion: @escaping (Result<UIView, any Error>) -> Void) {
        guard isIAUAvailble() else { return }
        
        let adConfiguration = OWIAUAdConfiguration.server(remote: .tmsServer(index: tmsServerIndex))
        let adSettings: OWIAUAdSettingsProtocol = OWIAUAdSettings(configuration: adConfiguration)
        
        OpenWebIAU.manager.ui.ad(postId: postId,
                                 settings: adSettings,
                                 viewEventCallbacks: nil,
                                 actionsCallbacks: nil,
                                 completion: { [weak self] result in
            switch result {
            case .success(let adView):
                completion(.success(adView))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
}

private extension OWMonetizationBridge {
    func isIAUAvailble() -> Bool {
        #if canImport(OpenWebIAUSDK)
            return true
        #else
            return false
        #endif
    }
}

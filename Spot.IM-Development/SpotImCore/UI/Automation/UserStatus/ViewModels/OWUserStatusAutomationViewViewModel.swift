//
//  OWUserStatusAutomationViewViewModel.swift
//  SpotImCore
//
//  Created by Alon Haiut on 26/10/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

#if AUTOMATION

import Foundation
import RxSwift

protocol OWUserStatusAutomationViewViewModelingInputs { }

protocol OWUserStatusAutomationViewViewModelingOutputs {
    var activeSpotId: OWSpotId { get }
    var activePostId: OWPostId { get }
    var userStatus: Observable<OWInternalUserAuthenticationStatus> { get }
    var showSDKNotInitializedWarning: Observable<Bool> { get }
}

protocol OWUserStatusAutomationViewViewModeling {
    var inputs: OWUserStatusAutomationViewViewModelingInputs { get }
    var outputs: OWUserStatusAutomationViewViewModelingOutputs { get }
}

class OWUserStatusAutomationViewViewModel: OWUserStatusAutomationViewViewModeling,
                                OWUserStatusAutomationViewViewModelingInputs,
                                OWUserStatusAutomationViewViewModelingOutputs {
    var inputs: OWUserStatusAutomationViewViewModelingInputs { return self }
    var outputs: OWUserStatusAutomationViewViewModelingOutputs { return self }

    lazy var activeSpotId: OWSpotId = {
        return OpenWeb.manager.spotId
    }()

    lazy var activePostId: OWPostId = {
        guard let manager = OpenWeb.manager as? OWManagerInternalProtocol,
              let postId = manager.postId else { return "" }
        return postId
    }()

    lazy var userStatus: Observable<OWInternalUserAuthenticationStatus> = {
        let authenticationManager = OWSharedServicesProvider.shared.authenticationManager()
        return authenticationManager.userAuthenticationStatus
    }()

    lazy var showSDKNotInitializedWarning: Observable<Bool> = {
        // This is based on the user authentication status + empty spot id
        let authenticationManager = OWSharedServicesProvider.shared.authenticationManager()
        return authenticationManager.userAuthenticationStatus
            .map { [weak self] status in
                guard let self = self,
                      status == .notAutenticated else { return false }
                return self.activeSpotId.isEmpty
            }
    }()
}

#endif

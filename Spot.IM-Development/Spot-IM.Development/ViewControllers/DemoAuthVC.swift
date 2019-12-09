//
//  YNetAuthVC.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 04/12/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

class DemoAuthVC: UIViewController {

}

extension DemoAuthVC: SSOAuthenticatable {
    var ssoAuthProvider: SPAuthenticationProvider { YnetAuthProvider() }
}

class YnetAuthProvider: SPAuthenticationProvider {
    func completeSSO(with codeB: String?, genericToken: String?, completion: @escaping AuthCompletionHandler) { }
    var ssoAuthDelegate: SSOAthenticationDelegate?
}

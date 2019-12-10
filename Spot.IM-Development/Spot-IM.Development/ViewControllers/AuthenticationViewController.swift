//
//  AuthenticstionViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 29/07/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

class AuthenticstionViewController: UIViewController, SSOAuthenticatable {
    
    var ssoAuthProvider: SPAuthenticationProvider = SPDefaultAuthProvider()

    @IBOutlet weak var genericTokenIndicator: UILabel!
    @IBOutlet weak var genericAuthenticationIndicator: UILabel!
    @IBOutlet weak var getGenericTokenButton: UIButton!
    @IBOutlet weak var getCodeAButton: UIButton!
    @IBOutlet weak var foxTokenIndicator: UILabel!
    
    let accessTokenNetwork = "03190715DchJcY"
    let username = "test"
    let password = "1234"
    
    var genericToken: String? {
        didSet { updateUI() }
    }
    var codeA: String?
    var codeB: String?
    var  genericAuthDone = false {
        didSet { updateUI() }
    }
    
    var foxAuthDone: Bool = false {
        didSet { updateUI() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func updateUI() {
        if genericToken == nil {
            genericTokenIndicator.text = "❌"
            getCodeAButton.isEnabled = false
        } else {
            genericTokenIndicator.text = "✅"
            getCodeAButton.isEnabled = true
        }
        
        genericAuthenticationIndicator.text = genericAuthDone ? "✅" : "❌"
        foxTokenIndicator.text = foxAuthDone ? "✅" : "❌"
    }
    
    @IBAction func logIn(_ sender: Any) {
        genericTokenIndicator.text = "⏳"
        DemoAuthenticationProvider.logIn(with: username, password: password) { (token, _) in
            self.genericToken = token
        }
    }
    
    @IBAction func startGenericSSO(_ sender: Any) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        SPClientSettings.main.setup(spotKey: .demoGenericSpotKeyForSSO)
        
        foxAuthDone = false
        genericAuthenticationIndicator.text = "⏳"
        ssoAuthProvider.startSSO { [weak self] response, error in
            if let error = error {
                print(error)
                self?.genericAuthDone = false
            } else {
                self?.codeA = response?.codeA
                self?.getCodeB(genericToken: response?.jwtToken)
            }
        }
    }
    
    @IBAction func startFoxSSO(_ sender: Any) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        SPClientSettings.main.setup(spotKey: .demoFoxSpotKeyForSSO)
        
        genericAuthDone = false
        foxTokenIndicator.text = "⏳"
        
        ssoAuthProvider.startSSO(with: .demoFoxSecretForSSO, completion: { (response, error) in
            if let error = error {
                print(error)
                self.foxAuthDone = false
            } else {
                if let autoComplete = response?.autoComplete, autoComplete {
                    self.foxAuthDone = response?.success ?? false
                } else {
                    self.codeA = response?.codeA
                    self.getCodeB()
                }
            }
        })
    }
    
    private func getCodeB(genericToken: String? = nil) {
        DemoAuthenticationProvider.getCodeB(
            with: codeA,
            accessToken: genericToken,
            username: username,
            accessTokenNetwork: accessTokenNetwork) { (codeB, error) in
                if let error = error {
                    print(error)
                    self.genericAuthDone = false
                } else {
                    self.codeB = codeB
                    self.completeSSO(genericToken: genericToken)
                }
        }
    }
    
    private func completeSSO(genericToken: String?) {
        ssoAuthProvider.completeSSO(with: codeB, genericToken: genericToken) { (success, error) in
            if let error = error {
                print(error)
                self.genericAuthDone = false
            } else if success {
                self.genericAuthDone = true
            } else {
                self.genericAuthDone = false
            }
        }
    }
    
    @IBAction func resetAllAuthentication(_ sender: Any) {
        codeA = nil
        codeB = nil
        genericToken = nil
        foxAuthDone = false
        genericAuthDone = false
    }
}

/// demo constants
private extension String {
    static var demoGenericSpotKeyForSSO: String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO: String { return "sp_ANQXRpqH" }
    static var demoFoxSecretForSSO: String { return  "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5REEwNkVEMjAxOCIsInR5cCI6IkpXVCJ9.eyJwaWQiOiJ1cy1lYXN0LTE6ZDc1ODUxZmEtNWZhZi00OWIwLWFmODktYjAwZTYzNTFhMWMwIiwidWlkIjoiWkRjMU9EVXhabUV0TldaaFppMDBPV0l3TFdGbU9Ea3RZakF3WlRZek5URmhNV013Iiwic2lkIjoiZmFmYTRjMTItZDQ5YS00NzQwLTljOTYtZTU2ZTc3ZThlZWZiIiwic2RjIjoidXMtZWFzdC0xIiwiYXR5cGUiOiJpZGVudGl0eSIsImR0eXBlIjoid2ViIiwidXR5cGUiOiJlbWFpbCIsImRpZCI6IiIsIm12cGRpZCI6IiIsInZlciI6MiwiZXhwIjoxNTk5NDY5MTY5LCJqdGkiOiJiMGFmODljNy04MGM4LTRlMzctODQ3Ny0zYTMwMjhiNzgxMjMiLCJpYXQiOjE1Njc5MzMxNjl9.SDExLf1C2yLBmIEGTUSOazVS7dKbdBSHeaewpcOLHnK_RjlxJCOj6RTn0RYsBw1cXgoeJvx9Hp9Hn0vtWcCkt9Hqz5eCY3zeIlxeRy9k0AcnkJEq-gIkA_S-DY47R20Ac_yNEfRf1h7uIkI8AbOz_7-327xpvc-le1mCmOhHt9Rx7pFf1QlIWIPsAD4y9cq4qQvyFylPOxM7KSdYqLeZzUKtsxnEmrHfGvAQw0fTaChiDmxmRKH-_unaWd_naGc3F120yw1BxuYatQu10cYKaFtr3mAbZEMJTrdnC77wXpCpNIKxER1xUemxX4bIiTf0vwdhYBcmDYhg6bmbzPqLfA"
    }
}

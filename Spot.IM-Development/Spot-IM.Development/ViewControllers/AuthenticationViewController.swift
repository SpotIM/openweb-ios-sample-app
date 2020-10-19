//
//  AuthenticstionViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 29/07/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

class AuthenticstionViewController: UIViewController {
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
        SpotIm.initialize(spotId: .demoGenericSpotKeyForSSO)
        
        foxAuthDone = false
        genericAuthenticationIndicator.text = "⏳"
        SpotIm.startSSO { [weak self] response, error in
            if let error = error {
                print(error)
                self?.genericAuthDone = false
                self?.genericAuthenticationIndicator.text = "❌"
            } else {
                self?.codeA = response?.codeA
                self?.getCodeB(genericToken: response?.jwtToken)
            }
        }
    }
    
    @IBAction func startFoxSSO(_ sender: Any) {
        // TODO: (Fedin) remove SPClientSettings.setup from here
        // when everything working with single key in AppDelegate
        SpotIm.initialize(spotId: .demoFoxSpotKeyForSSO)
        
        genericAuthDone = false
        foxTokenIndicator.text = "⏳"
    
        SpotIm.getUserLoginStatus { (loginStatus) in
            print("BEFORE login \(loginStatus))")
            SpotIm.sso(withJwtSecret: .demoFoxSecretForSSO, completion: { (response, error) in
                if let error = error {
                    print(error)
                    self.foxAuthDone = false
                } else {
                    SpotIm.getUserLoginStatus { loginStatus in
                        print("After login \(loginStatus))")
                    }
                    if let autoComplete = response?.autoComplete, autoComplete {
                        self.foxAuthDone = response?.success ?? false
                    } else {
                        self.codeA = response?.codeA
                        self.getCodeB()
                    }
                }
            })
        }
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
                    self.completeSSO(codeB: codeB!)
                }
        }
    }
    
    private func completeSSO(codeB: String) {
        SpotIm.completeSSO(with: codeB) { (success, error) in
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
        SpotIm.getUserLoginStatus { (loginStatus) in
            print("BEFORE logout \(loginStatus))")
            SpotIm.logout { result in
                switch result {
                case .success():
                    SpotIm.getUserLoginStatus { loginStatus in
                        print("AFTER logout \(loginStatus))")
                    }
                    self.codeA = nil
                    self.genericToken = nil
                    self.foxAuthDone = false
                    self.genericAuthDone = false
                case .failure(let error):
                    print("Logout error: \(error)")
                @unknown default:
                    fatalError()
                }
                
            }
        }
    }
}

/// demo constants
private extension String {
    static var demoGenericSpotKeyForSSO: String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO: String { return "sp_ANQXRpqH" }
    static var demoFoxSecretForSSO: String { return  "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5REEwNkVEMjAxOCIsInR5cCI6IkpXVCJ9.eyJwaWQiOiJ1cy1lYXN0LTE6ZDc1ODUxZmEtNWZhZi00OWIwLWFmODktYjAwZTYzNTFhMWMwIiwidWlkIjoiWkRjMU9EVXhabUV0TldaaFppMDBPV0l3TFdGbU9Ea3RZakF3WlRZek5URmhNV013Iiwic2lkIjoiZDJiNTE2ZGItMDBjYy00MTJhLWFmZmMtZTllMWFhYmI4NTAwIiwic2RjIjoidXMtZWFzdC0xIiwiYXR5cGUiOiJpZGVudGl0eSIsImR0eXBlIjoid2ViIiwidXR5cGUiOiJlbWFpbCIsImRpZCI6IiIsIm12cGRpZCI6IiIsInZlciI6MiwiZXhwIjoxNjMzNTk1MjMxLCJqdGkiOiIxYTQ5MjMyNi1hYzIyLTQ2MjItOGE1MS1mYTJjMjQwMjc5YjUiLCJpYXQiOjE2MDIwNTkyMzF9.BfBv3vGsj5Zd17nNDf1tetgUozIUvuBHj6ReBp-7TwJ3IFfbx7QSXiHVvKsnX_8DguH6uSdRQfjtUpteDRovvJ6Qq2uVUWUWd9XfD_QV6UsYhQph7Hfb5WzIVtEWf1Tu6Gm4RpgEGg37EnKSoDPeRkp9vBnj6fAGv2DKQUag3V-XbQJ7P98upfyMMkQY3e_COJF9HpDVdruJGB2iWu-pW81gjgzjGLupGSQKWp4bZz6dB9XvT06jgLY3IBMdZzRaWQfmBEsrHCNJZBgWyjjzs0PeZzRODOhUW3udoZSCXXsIZg7KKg_fOioEP9MG_QOoOZvElT9I3g1wtSKbX7so8g"
    }
}


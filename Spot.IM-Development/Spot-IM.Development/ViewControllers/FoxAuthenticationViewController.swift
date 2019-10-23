//
//  FoxAuthenticationViewController.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 14/09/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore

enum FoxError: Error {
    case runtimeError(String)
}

class FoxAuthenticationViewController: UIViewController, SSOAuthenticatable {
    
    var ssoAuthProvider: SPAuthenticationProvider = SPDefaultAuthProvider()
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Authentication"
    }
    
    @IBAction func signIn(_ sender: Any) {
        guard let email = self.emailTextfield.text, let password = passwordTextField.text else {
            return
        }
        
        self.authenticate(email: email, password: password) {[weak self] (token, error) in
            DispatchQueue.main.sync {
                guard let token = token else {
                    self?.alert(text: error ?? "No description")
                    return
                }
                
                self?.authenticateWithSpotIm(token: token)
            }
        }
    }
    
    private func alert(text:String) {
        let alert = UIAlertController(title: "Failed authenticating with Fox", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
           }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func authenticateWithSpotIm(token:String) {
        ssoAuthProvider.startSSO(with: token, completion: { [weak self] response, error in
            if let success = response?.success, success {
                print("Authentication successful!")
                self?.ssoAuthProvider.ssoAuthDelegate?.ssoFlowDidSucceed()
            } else {
                print("Authentication error:\n\(String(describing: error))")
                self?.ssoAuthProvider.ssoAuthDelegate?.ssoFlowDidFail(with: error)
            }
        })
    }
    
    @IBAction func createAccountTapped(_ sender: Any) {
        if let url = URL(string: "https://my.foxnews.com/?p=create-account") {
            UIApplication.shared.open(url)
        }
    }
    private func authenticate(email:String, password:String,  completion: @escaping (_ token: String?, _ error: String?) -> Void) {
        
        let parameters = ["email": email, "password": password]
        
        let url = URL(string: "https://api2.fox.com/v2.0/login")!
        
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.setValue("vHeTnXOe984VBvC0ud8lPpSbsxJ0c7kQ", forHTTPHeaderField: "x-api-key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            
            guard error == nil else {
                completion(nil, nil)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let token = json["accessToken"] as? String {
                        completion(token, nil)
                        return
                    }
                    
                    if let type = json["@type"] as? String, type == "Error", let detail = json["detail"] as? String{
                        completion(nil, detail)
                        return
                    }
                  
                }
                completion(nil, nil)
            } catch let error {
                completion(nil, error.localizedDescription)
            }
        })
        task.resume()
    }
}

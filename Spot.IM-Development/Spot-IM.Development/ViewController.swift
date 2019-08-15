//
//  ViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Spot_IM_Core
import Crashlytics

class ViewController: UIViewController {

    let authProvider = SPDefaultAuthProvider()

    @IBOutlet weak var logo: UIImageView!
    @IBAction func showMainConversation(_ sender: UIButton) {
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoGenericSpotKeyForSSO), animated: true)
    }
    
    @IBAction func showFoxMainConversation(_ sender: UIButton) {
        
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoFoxSpotKeyForSSO), animated: true)
        
        // Authenticate on the background.
        let params = SSOStartParameters(token: nil, secret: .demoFoxSecretForSSO)
        authProvider.startSSO(with: params, completion: { (response, error) in
            if let error = error {
                print(error)
            }
        })
    }

    @IBAction func showDemoSpotConversation(_ sender: Any) {
        navigationController?.pushViewController(ArticlesListViewController(spotId: .demoMainSpotKey), animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        logo.clipsToBounds = true
        logo.layer.cornerRadius = 8
    }
    
    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
}

/// demo constants
private extension String {
    static var demoGenericSpotKeyForSSO:    String { return "sp_eCIlROSD" }
    static var demoFoxSpotKeyForSSO:        String { return "sp_ANQXRpqH" }
    static var demoMainSpotKey:             String { return "sp_ly3RvXf6" }
    static var demoFoxSecretForSSO:         String { return  "eyJhbGciOiJSUzI1NiIsImtpZCI6Ijg5REEwNkVEMjAxOCIsInR5cCI6IkpXVCJ9.eyJwaWQiOiJ1cy1lYXN0LTE6YjJkZDYyMzEtZGZkNS00MDU4LWI1ZDAtNDE5YjcxM2U3MmQ1IiwidWlkIjoiWWpKa1pEWXlNekV0Wkdaa05TMDBNRFU0TFdJMVpEQXROREU1WWpjeE0yVTNNbVExIiwic2lkIjoiNDBhNDhkZTAtODAyMy00OWQzLWJhYjgtNTU4MjBiYzBhMWI1Iiwic2RjIjoidXMtZWFzdC0xIiwiYXR5cGUiOiJpZGVudGl0eSIsImR0eXBlIjoid2ViIiwidXR5cGUiOiJlbWFpbCIsImRpZCI6IiIsIm12cGRpZCI6IiIsInZlciI6MiwiZXhwIjoxNTkzNjgyNzU3LCJqdGkiOiIyOWRjNGM3OS1kZWQ0LTQzNGUtYjc2Ni1iMjkzODM4YzQwNGMiLCJpYXQiOjE1NjIxNDY3NTd9.jACKyPFVpZEIa5lM9hgNbYUZzim4dTbb8nxr9C6hxNtnPNORTihpkfMK9gkFAnTP0hnPClqZUL_n-IM1HzHVzISztKEK9MRsC3JlCCL122syhtunQQnWp5xXX-Rn8hl-wM8ars4PK2izoFfyDInd-dw55kkTo6NryW-lLWcwbZFxXneb7MMvjpcuGB9N_g27VsK1nneUEFMZI1HchZNQmBUGyFRaH6ZxQ9ehFqpGEMIobaw6oN-tKDTjXqfpuyEm0QjWYGWVFF8pwLp9hHGuey2GuyScyd7NBtP7DZ_3_MKSbJeGBqpxc0yiRzKtgumY76lZgiW1LL38EMtUWIbIMw"
    }
}


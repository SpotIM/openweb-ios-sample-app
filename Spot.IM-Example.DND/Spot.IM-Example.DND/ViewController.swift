//
//  ViewController.swift
//  Spot.IM-Example.DND
//
//  Created by Andriy Fedin on 19/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Spot_IM_Core

class ViewController: UIViewController {

    let conversationId = "p0st1"

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.showMainConversation(with: self.conversationId)
        }
    }

    @IBAction func showMainConversation(_ sender: UIButton) {
        showMainConversation(with: conversationId)
    }

    private func showMainConversation(with id: String) {
        let mainConversationVC = SPMainConversationVC(with: id)
        navigationController?.pushViewController(mainConversationVC, animated: true)
    }

    private func setupUI() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
    }
}

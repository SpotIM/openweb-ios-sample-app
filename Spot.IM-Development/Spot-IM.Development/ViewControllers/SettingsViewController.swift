//
//  SettingsViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 17/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import SpotImCore

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var hideArtcleHeaderSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var modeControl: UISegmentedControl!
    
    private var navBarHiddenOldValue = false
    var isCustomDarkModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "demo.isCustomDarkModeEnabled") }
        set { setCustomDarkMode(enabled: newValue) }
    }
    
    var isHideArticleHeaderEnabled: Bool {
        get { !SpotIm.displayArticleHeader }
        set { SpotIm.displayArticleHeader = !newValue }
    }
    
    var interfaceStyle: Int {
        get { UserDefaults.standard.integer(forKey: "demo.interfaceStyle") }
        set { UserDefaults.standard.set(newValue, forKey: "demo.interfaceStyle") }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        darkModeSwitch.isOn = isCustomDarkModeEnabled
        hideArtcleHeaderSwitch.isOn = isHideArticleHeaderEnabled
        
        modeControl.isHidden = !isCustomDarkModeEnabled
        modeControl.selectedSegmentIndex = interfaceStyle
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(navBarHiddenOldValue, animated: animated)
    }
    
    @IBAction func switchHideArticleHeader(_ sender: UISwitch) {
        isHideArticleHeaderEnabled = sender.isOn
    }
    

    @IBAction func switchDarkMode(_ sender: UISwitch) {
        isCustomDarkModeEnabled = sender.isOn
    }

    @IBAction func changeMode(_ sender: UISegmentedControl) {
        interfaceStyle = sender.selectedSegmentIndex
        let style: SPUserInterfaceStyle = interfaceStyle == 0 ? .light : .dark
        SpotIm.overrideUserInterfaceStyle = style
    }

    private func setCustomDarkMode(enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: "demo.isCustomDarkModeEnabled")
        modeControl.isHidden = !enabled

        if enabled {
            let style: SPUserInterfaceStyle = interfaceStyle == 0 ? .light : .dark
            SpotIm.overrideUserInterfaceStyle = style
        } else {
            SpotIm.overrideUserInterfaceStyle = nil
        }
    }

}

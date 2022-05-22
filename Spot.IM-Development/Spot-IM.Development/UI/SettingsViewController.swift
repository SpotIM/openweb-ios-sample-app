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
    @IBOutlet weak var createCommentNewDesignSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var buttonOnlyModeControl: UISegmentedControl!
    @IBOutlet weak var readOnlyModeControl: UISegmentedControl!
    @IBOutlet weak var enableCustomNavigationTitleSwitch: UISwitch!
    
    private var navBarHiddenOldValue = false
    var isCustomDarkModeEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "demo.isCustomDarkModeEnabled") }
        set { setCustomDarkMode(enabled: newValue) }
    }
    
    var isHideArticleHeaderEnabled: Bool {
        get { !SpotIm.displayArticleHeader }
        set { SpotIm.displayArticleHeader = !newValue }
    }
    
    var isCreateCommentNewDesignEnabled: Bool {
        get { SpotIm.enableCreateCommentNewDesign }
        set { SpotIm.enableCreateCommentNewDesign = newValue }
    }
    
    var isCustomNavigationTitleEnabled: Bool {
        get { SpotIm.enableCustomNavigationItemTitle }
        set { SpotIm.enableCustomNavigationItemTitle = newValue }
    }
    
    var readOnlyModeIndex: Int {
        get { UserDefaults.standard.integer(forKey: "demo.isReadOnlyEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "demo.isReadOnlyEnabled") }
    }
    
    var interfaceStyle: Int {
        get { UserDefaults.standard.integer(forKey: "demo.interfaceStyle") }
        set { UserDefaults.standard.set(newValue, forKey: "demo.interfaceStyle") }
    }
    
    var buttonOnlyModeIndex: Int {
        get {
            switch (SpotIm.getButtonOnlyMode()) {
            case .disable:
                return 0
            case .withTitle:
                return 1
            case .withoutTitle:
                return 2
            default:
                return 0
            } }
        set {
            var newMode = SpotImButtonOnlyMode.disable
            switch newValue {
            case 0:
                newMode = .disable
                break
            case 1:
                newMode = .withTitle
                break
            case 2:
                newMode = .withoutTitle
                break
            default:
                break
            }
            SpotIm.setButtonOnlyMode(mode: newMode)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        darkModeSwitch.isOn = isCustomDarkModeEnabled
        hideArtcleHeaderSwitch.isOn = isHideArticleHeaderEnabled
        createCommentNewDesignSwitch.isOn = isCreateCommentNewDesignEnabled
        buttonOnlyModeControl.selectedSegmentIndex = buttonOnlyModeIndex
        readOnlyModeControl.selectedSegmentIndex = readOnlyModeIndex
        enableCustomNavigationTitleSwitch.isOn = isCustomNavigationTitleEnabled
        
        modeControl.isHidden = !isCustomDarkModeEnabled
        modeControl.selectedSegmentIndex = interfaceStyle
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(navBarHiddenOldValue, animated: animated)
    }
    
    @IBAction func switchHideArticleHeader(_ sender: UISwitch) {
        isHideArticleHeaderEnabled = sender.isOn
    }
    
    @IBAction func switchCreateCommentNewDesign(_ sender: UISwitch) {
        isCreateCommentNewDesignEnabled = sender.isOn
    }
    
    @IBAction func changeButtonOnlyMode(_ sender: UISegmentedControl) {
        buttonOnlyModeIndex = sender.selectedSegmentIndex
    }
    

    @IBAction func switchDarkMode(_ sender: UISwitch) {
        isCustomDarkModeEnabled = sender.isOn
    }

    @IBAction func changeMode(_ sender: UISegmentedControl) {
        interfaceStyle = sender.selectedSegmentIndex
        let style: SPUserInterfaceStyle = interfaceStyle == 0 ? .light : .dark
        SpotIm.overrideUserInterfaceStyle = style
    }
    
    @IBAction func changeReadOnlyMode(_ sender: UISegmentedControl) {
        readOnlyModeIndex = sender.selectedSegmentIndex
    }
    
    
    @IBAction func switchEnableCustomNavigationTitle(_ sender: UISwitch) {
        isCustomNavigationTitleEnabled = sender.isOn
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

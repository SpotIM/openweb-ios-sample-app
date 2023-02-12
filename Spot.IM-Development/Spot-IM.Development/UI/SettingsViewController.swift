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
    
    fileprivate struct Metrics {
        static let identifier = "settings_view_controller_id"
        static let hideArtcleHeaderSwitchIdentifier = "hide_artcle_header_switch_id"
        static let createCommentNewDesignSwitchIdentifier = "create_comment_new_design_switch_id"
        static let darkModeSwitchIdentifier = "dark_mode_switch_id"
        static let modeControlIdentifier = "mode_control_id"
        static let buttonOnlyModeControlIdentifier = "button_only_mode_control_id"
        static let readOnlyModeControlIdentifier = "read_only_mode_control_id"
        static let enableCustomNavigationTitleSwitchIdentifier = "enable_custom_navigation_title_switch_id"
    }
    
    @IBOutlet weak var hideArtcleHeaderSwitch: UISwitch!
    @IBOutlet weak var createCommentNewDesignSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var modeControl: UISegmentedControl!
    @IBOutlet weak var buttonOnlyModeControl: UISegmentedControl!
    @IBOutlet weak var readOnlyModeControl: UISegmentedControl!
    @IBOutlet weak var enableCustomNavigationTitleSwitch: UISwitch!

    private var navBarHiddenOldValue = false
    var isCustomDarkModeEnabled: Bool {
        get { UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<Bool>.isCustomDarkModeEnabled,
                                              defaultValue: false) }
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
        get { UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<Int>.isReadOnlyEnabled, defaultValue: 0) }
        set { UserDefaultsProvider.shared.save(value: newValue, forKey: .isReadOnlyEnabled) }
    }

    var interfaceStyle: Int {
        get { UserDefaultsProvider.shared.get(key: UserDefaultsProvider.UDKey<Int>.interfaceStyle, defaultValue: 0) }
        set { UserDefaultsProvider.shared.save(value: newValue, forKey: .interfaceStyle) }
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

            case 1:
                newMode = .withTitle

            case 2:
                newMode = .withoutTitle

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
        
        view.backgroundColor = ColorPalette.shared.color(type: .background)
    }

    override func loadView() {
        super.loadView()
        applyAccessibility()
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
        UserDefaultsProvider.shared.save(value: enabled, forKey: .isCustomDarkModeEnabled)
        modeControl.isHidden = !enabled

        if enabled {
            let style: SPUserInterfaceStyle = interfaceStyle == 0 ? .light : .dark
            SpotIm.overrideUserInterfaceStyle = style
        } else {
            SpotIm.overrideUserInterfaceStyle = nil
        }
    }
}

fileprivate extension SettingsViewController {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        hideArtcleHeaderSwitch.accessibilityIdentifier = Metrics.hideArtcleHeaderSwitchIdentifier
        createCommentNewDesignSwitch.accessibilityIdentifier = Metrics.createCommentNewDesignSwitchIdentifier
        darkModeSwitch.accessibilityIdentifier = Metrics.darkModeSwitchIdentifier
        modeControl.accessibilityIdentifier = Metrics.modeControlIdentifier
        buttonOnlyModeControl.accessibilityIdentifier = Metrics.buttonOnlyModeControlIdentifier
        readOnlyModeControl.accessibilityIdentifier = Metrics.readOnlyModeControlIdentifier
        enableCustomNavigationTitleSwitch.accessibilityIdentifier = Metrics.enableCustomNavigationTitleSwitchIdentifier
    }
}

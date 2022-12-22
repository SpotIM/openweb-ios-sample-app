//
//  SettingsViewModel.swift
//  Spot-IM.Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

protocol SettingsViewModelingInputs {
    var hideArticleHeaderToggled: PublishSubject<Bool> { get }
    var commentCreationNewDesignToggled: PublishSubject<Bool> { get }
    var readOnlyModeSelectedIndex: PublishSubject<Int> { get }
    var themeModeSelectedIndex: PublishSubject<Int> { get }
    var modalStyleSelectedIndex: PublishSubject<Int> { get }
}

protocol SettingsViewModelingOutputs {
    var title: String { get }
    var hideArticleHeaderTitle: String { get }
    var commentCreationNewDesignTitle: String { get }
    var readOnlyTitle: String { get }
    var readOnlySettings: [String] { get }
    var themeModeTitle: String { get }
    var themeModeSettings: [String] { get }
    var modalStyleTitle: String { get }
    var modalStyleSettings: [String] { get }
}

protocol SettingsViewModeling {
    var inputs: SettingsViewModelingInputs { get }
    var outputs: SettingsViewModelingOutputs { get }
}

class SettingsViewModel: SettingsViewModeling, SettingsViewModelingInputs, SettingsViewModelingOutputs {
    var inputs: SettingsViewModelingInputs { return self }
    var outputs: SettingsViewModelingOutputs { return self }
    
    fileprivate let shouldHideArticleHeader = BehaviorSubject(value: false)
    var hideArticleHeaderToggled = PublishSubject<Bool>()
    
    fileprivate let shouldCommentCreationNewDesign = BehaviorSubject(value: false)
    var commentCreationNewDesignToggled = PublishSubject<Bool>()
    
    fileprivate let _readOnlyModeSelectedIndex = BehaviorSubject(value: 0)
    var readOnlyModeSelectedIndex = PublishSubject<Int>()
    
    fileprivate let _themeModeSelectedIndex = BehaviorSubject(value: 0)
    var themeModeSelectedIndex = PublishSubject<Int>()
    
    fileprivate let _modalStyleSelectedIndex = BehaviorSubject(value: 0)
    var modalStyleSelectedIndex = PublishSubject<Int>()
    
    fileprivate let disposeBag = DisposeBag()
    
    lazy var title: String = {
        return NSLocalizedString("Settings", comment: "")
    }()
    
    lazy var hideArticleHeaderTitle: String = {
        return NSLocalizedString("HideArticleHeader", comment: "")
    }()
    
    lazy var commentCreationNewDesignTitle: String = {
        return NSLocalizedString("CommentCreationNewDesign", comment: "")
    }()
    
    lazy var readOnlyTitle: String = {
        return NSLocalizedString("ReadOnlyMode", comment: "")
    }()
    
    lazy var readOnlySettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _enabled = NSLocalizedString("Enabled", comment: "")
        let _disabled = NSLocalizedString("Disabled", comment: "")
        
        return [_default, _enabled, _disabled]
    }()
    
    lazy var themeModeTitle: String = {
        return NSLocalizedString("ThemeMode", comment: "")
    }()
    
    lazy var themeModeSettings: [String] = {
        let _default = NSLocalizedString("Default", comment: "")
        let _light = NSLocalizedString("Light", comment: "")
        let _dark = NSLocalizedString("Dark", comment: "")
        
        return [_default, _light, _dark]
    }()
    
    lazy var modalStyleTitle: String = {
        return NSLocalizedString("ModalStyle", comment: "")
    }()
    
    lazy var modalStyleSettings: [String] = {
        let _fullScreen = NSLocalizedString("FullScreen", comment: "")
        let _pageSheet = NSLocalizedString("PageSheet", comment: "")
        
        return [_fullScreen, _pageSheet]
    }()
    
    init() {
        setupObservers()
    }
}

extension SettingsViewModel {
    func setupObservers() {
        
        // Bind hide article header toggle
        hideArticleHeaderToggled
            .do(onNext: { _ in
                // TODO: should be done
            })
            .bind(to: shouldHideArticleHeader)
            .disposed(by: disposeBag)
                
        // Bind comment creation new design toggle
        commentCreationNewDesignToggled
            .do(onNext: { _ in
                // TODO: should be done
            })
            .bind(to: shouldCommentCreationNewDesign)
            .disposed(by: disposeBag)
                
        // Different read only mode selected
        readOnlyModeSelectedIndex
            .bind(to: _readOnlyModeSelectedIndex)
            .disposed(by: disposeBag)
                
        // Different theme mode selected
        themeModeSelectedIndex
            .bind(to: _themeModeSelectedIndex)
            .disposed(by: disposeBag)
                
        // Different modal style selected
        modalStyleSelectedIndex
            .bind(to: _modalStyleSelectedIndex)
            .disposed(by: disposeBag)
    }
}

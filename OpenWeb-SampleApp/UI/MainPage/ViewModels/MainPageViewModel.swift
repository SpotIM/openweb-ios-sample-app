//
//  MainPageViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import RxSwift

protocol MainPageViewModelingInputs {
    var testAPITapped: PublishSubject<Void> { get }
    var aboutTapped: PublishSubject<Void> { get }
}

protocol MainPageViewModelingOutputs {
    var title: String { get }
    var versionText: String { get }
    var buildText: String { get }
    var welcomeText: String { get }
    var showAbout: Observable<Void> { get }
    var testAPI: Observable<Void> { get }
}

protocol MainPageViewModeling {
    var inputs: MainPageViewModelingInputs { get }
    var outputs: MainPageViewModelingOutputs { get }
}

class MainPageViewModel: MainPageViewModeling, MainPageViewModelingInputs, MainPageViewModelingOutputs {
    var inputs: MainPageViewModelingInputs { return self }
    var outputs: MainPageViewModelingOutputs { return self }

    lazy var title: String = {
        return NSLocalizedString("SampleApp", comment: "")
    }()

    lazy var welcomeText: String = {
        return NSLocalizedString("WelcomeDescription", comment: "")
    }()

    lazy var versionText: String = {
        var versionNumber = ""
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionNumber = version
        }

        return "\(NSLocalizedString("Vesrion", comment: "")): \(versionNumber)"
    }()

    lazy var buildText: String = {
        var buildNumber = ""
        if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            buildNumber = build
        }

        return "\(NSLocalizedString("Build", comment: "")): \(buildNumber)"
    }()

    let testAPITapped = PublishSubject<Void>()
    let aboutTapped = PublishSubject<Void>()

    var showAbout: Observable<Void> {
        aboutTapped
            .asObservable()
    }

    var testAPI: Observable<Void> {
        testAPITapped
            .asObservable()
    }
}

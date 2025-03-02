//
//  MainPageViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation
import Combine

protocol MainPageViewModelingInputs {
    var testAPITapped: PassthroughSubject<Void, Never> { get }
    var aboutTapped: PassthroughSubject<Void, Never> { get }
}

protocol MainPageViewModelingOutputs {
    var title: String { get }
    var versionText: String { get }
    var buildText: String { get }
    var welcomeText: String { get }
    var descriptionText: String { get }
    var showAbout: AnyPublisher<Void, Never> { get }
    var testAPI: AnyPublisher<Void, Never> { get }
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
        return NSLocalizedString("WelcomeText", comment: "")
    }()

    lazy var descriptionText: String = {
        return NSLocalizedString("DescriptionText", comment: "")
    }()

    lazy var versionText: String = {
        var versionNumber = ""
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            versionNumber = version
        }

        return "v \(versionNumber)"
    }()

    lazy var buildText: String = {
        var buildNumber = ""
        if let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            buildNumber = build
        }

        return "\(NSLocalizedString("Build", comment: "")): \(buildNumber)"
    }()

    let testAPITapped = PassthroughSubject<Void, Never>()
    let aboutTapped = PassthroughSubject<Void, Never>()

    var showAbout: AnyPublisher<Void, Never> {
        aboutTapped
            .eraseToAnyPublisher()
    }

    var testAPI: AnyPublisher<Void, Never> {
        testAPITapped
            .eraseToAnyPublisher()
    }
}

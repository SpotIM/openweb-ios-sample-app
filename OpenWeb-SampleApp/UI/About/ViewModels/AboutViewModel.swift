//
//  AboutViewModel.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import Foundation

protocol AboutViewModelingInputs { }

protocol AboutViewModelingOutputs {
    var title: String { get }
    var aboutText: String { get }
    var allRightsReserved: String { get }
}

protocol AboutViewModeling {
    var inputs: AboutViewModelingInputs { get }
    var outputs: AboutViewModelingOutputs { get }
}

class AboutViewModel: AboutViewModeling, AboutViewModelingInputs, AboutViewModelingOutputs {
    var inputs: AboutViewModelingInputs { return self }
    var outputs: AboutViewModelingOutputs { return self }

    lazy var title: String = {
        return NSLocalizedString("About", comment: "")
    }()

    lazy var aboutText: String = {
        return NSLocalizedString("AboutText", comment: "")
    }()

    lazy var allRightsReserved: String = {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let allRightsReserved = NSLocalizedString("allRightsReserved", comment: "")
        return String(format: allRightsReserved, "\(year)")
    }()
}

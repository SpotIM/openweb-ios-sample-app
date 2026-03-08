//
//  SettingsScreenViewModel.swift
//  OpenWeb-Showcase
//
//  Created by  Nogah Melamed on 08/03/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.
//

import SwiftUI
import Combine

class SettingsScreenViewModel: ObservableObject {
    let sections: [SettingsSection] = SettingsSection.allCases
}

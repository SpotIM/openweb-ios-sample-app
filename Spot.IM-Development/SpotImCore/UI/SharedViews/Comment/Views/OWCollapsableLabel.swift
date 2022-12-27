//
//  OWCollapsableLabel.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 27/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWCollapsableLabel: UILabel {
    fileprivate var viewModel: OWCollapsableLabelViewModeling
    
    init(lineLimit: Int, text: NSMutableAttributedString) {
        viewModel = OWCollapsableLabelViewModel(text: text, lineLimit: lineLimit)
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

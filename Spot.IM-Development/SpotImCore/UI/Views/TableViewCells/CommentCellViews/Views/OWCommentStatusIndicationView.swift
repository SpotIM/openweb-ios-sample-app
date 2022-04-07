//
//  OWCommentStatusIndicationView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/04/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

class OWCommentStatusIndicationView: OWBaseView {
    private let iconImageView: UIImageView = .init()
    private let statusTextLabel: OWBaseLabel = .init()
    private let statusExplanationButton: OWBaseButton = .init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .iceBlue
    }
}

//
//  OWCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// TODO: complete
internal final class OWCommunityGuidelinesView: OWBaseView {
    
    fileprivate let viewModel: OWCommunityGuidelinesViewModeling
    
    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

}

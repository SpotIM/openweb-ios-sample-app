//
//  OWPreConversationFooterView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// TODO: complete
internal final class OWPreConversationFooterView: OWBaseView {
    
    fileprivate let viewModel: OWPreConversationFooterViewModeling
    
    init(with viewModel: OWPreConversationFooterViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
    }

}

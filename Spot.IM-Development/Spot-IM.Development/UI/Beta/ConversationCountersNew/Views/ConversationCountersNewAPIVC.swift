//
//  ConversationCountersNewAPIVC.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 19/09/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

#if NEW_API

class ConversationCountersNewAPIVC: UIViewController {
    fileprivate let viewModel: ConversationCountersNewAPIViewModeling
    init(viewModel: ConversationCountersNewAPIViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = .blue
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif

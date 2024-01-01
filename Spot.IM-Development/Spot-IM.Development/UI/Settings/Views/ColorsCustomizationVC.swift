//
//  ColorsCustomizationVC.swift
//  Spot-IM.Development
//
//  Created by  Nogah Melamed on 31/12/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ColorsCustomizationVC: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "colors_customization_vc_id"
        static let verticalOffset: CGFloat = 40
        static let verticalBetweenSettingViewsOffset: CGFloat = 80
    }

    fileprivate let viewModel: ColorsCustomizationViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(viewModel: ColorsCustomizationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        setupViews()
    }
}

fileprivate extension ColorsCustomizationVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

    }
}

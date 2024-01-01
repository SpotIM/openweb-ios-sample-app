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

@available(iOS 14.0, *)
class ColorsCustomizationVC: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "colors_customization_vc_id"
        static let horizontalOffset: CGFloat = 40
        static let stackViewSpacing: CGFloat = 20
    }

    fileprivate let viewModel: ColorsCustomizationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var scrollView: UIScrollView = {
        return UIScrollView()
    }()

    fileprivate lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = Metrics.stackViewSpacing
        return stackView
    }()

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupObservers()
    }
}

@available(iOS 14.0, *)
extension ColorsCustomizationVC: UIColorPickerViewControllerDelegate {

}

@available(iOS 14.0, *)
fileprivate extension ColorsCustomizationVC {
    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        applyLargeTitlesIfNeeded()

        title = viewModel.outputs.title

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView.contentLayoutGuide).inset(Metrics.horizontalOffset)
            make.leading.trailing.equalTo(scrollView)
        }

        viewModel.outputs.colorItems.forEach { item in
            let view = ColorSelectionItemView(item: item, showPicker: showPicker(picker:))
            stackView.addArrangedSubview(view)
        }
    }

    func setupObservers() {
    }

    func showPicker(picker: UIColorPickerViewController) {
        self.present(picker, animated: true)
    }
}

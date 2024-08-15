//
//  AboutVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import SnapKit

class AboutVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let identifier = "about_vc_id"
        static let textViewIdentifier = "about_text_view_id"
        static let rightsReservedIdentifier = "rights_reserved_label_id"
    }

    fileprivate let viewModel: AboutViewModeling

    fileprivate lazy var aboutTextView: UITextView = {
        let textView = UITextView()
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .blackish))

        return textView
    }()

    fileprivate lazy var allRightsReservedLbl: UILabel = {
        return UILabel()
            .textColor(ColorPalette.shared.color(type: .darkGrey))
            .font(FontBook.paragraphBold)
            .textAlignment(.center)
    }()

    init(viewModel: AboutViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
}

fileprivate extension AboutVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        aboutTextView.accessibilityIdentifier = Metrics.textViewIdentifier
        allRightsReservedLbl.accessibilityIdentifier = Metrics.rightsReservedIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        view.addSubview(aboutTextView)
        view.addSubview(allRightsReservedLbl)

        aboutTextView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalMargin)
            make.bottom.equalTo(allRightsReservedLbl.snp.top).offset(-Metrics.verticalMargin)
        }

        allRightsReservedLbl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-Metrics.verticalMargin)
            make.leading.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(Metrics.horizontalMargin)
            make.centerX.equalToSuperview()
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        aboutTextView.text = viewModel.outputs.aboutText
        allRightsReservedLbl.text = viewModel.outputs.allRightsReserved
    }
}

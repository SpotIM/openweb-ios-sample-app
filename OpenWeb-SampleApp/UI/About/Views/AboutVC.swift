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
    private struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let identifier = "about_vc_id"
        static let textViewIdentifier = "about_text_view_id"
        static let rightsReservedIdentifier = "rights_reserved_label_id"
    }

    private let viewModel: AboutViewModeling

    private lazy var aboutTextView: UITextView = {
        let textView = UITextView()
            .font(FontBook.paragraphMedium)
            .textColor(.L_6)

        return textView
    }()

    private lazy var allRightsReservedLbl: UILabel = {
        return UILabel()
            .textColor(.L_4)
            .font(FontBook.helper)
            .textAlignment(.center)
    }()

    init(viewModel: AboutViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}

private extension AboutVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        aboutTextView.accessibilityIdentifier = Metrics.textViewIdentifier
        allRightsReservedLbl.accessibilityIdentifier = Metrics.rightsReservedIdentifier
    }

    @objc func setupViews() {
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

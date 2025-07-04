//
//  MainPageVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import SnapKit
import Combine
import CombineCocoa

class MainPageVC: UIViewController {
    private struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        static let identifier = "main_page_vc_id"
        static let logoIdentifier = "open_web_logo_id"
        static let sampleAppImageIdentifier = "sample_app_image_id"
        static let welcomeTextIdentifier = "welcome_text_id"
        static let descriptionTextIdentifier = "description_text_id"
        static let versionIdentifier = "version_text_id"
        static let buildIdentifier = "build_text_id"
        static let exploreButtonIdentifier = "test_api_btn_id" // identifier as before for QA automation tests to work
        static let aboutBarButtonIdentifier = "about_btn_id"
        static let buttonHeight: CGFloat = 40
    }

    private let viewModel: MainPageViewModeling
    private var cancellables = Set<AnyCancellable>()

    private lazy var welcomeLbl: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .textColor(.L_6)
            .font(FontBook.mainHeadingBold)
            .textAlignment(.center)
    }()

    private lazy var descriptionLbl: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .textColor(.L_6)
            .font(FontBook.paragraph)
            .textAlignment(.center)
    }()

    private lazy var versionLbl: UILabel = {
        return UILabel()
            .textColor(.L_5)
            .font(FontBook.helper)
    }()

    private lazy var buildLbl: UILabel = {
        return UILabel()
            .textColor(.L_5)
            .font(FontBook.helper)
    }()

    private lazy var exploreAPIBtn: UIButton = {
        return NSLocalizedString("Explore", comment: "").blueRoundedButton
    }()

    private lazy var logoImgView: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "openWebLogo")!)
            .contentMode(.scaleAspectFit)
    }()

    private lazy var sampleAppImgView: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "sampleApp-illustration")!)
            .contentMode(.scaleAspectFit)
    }()

    private lazy var aboutBtn: UIButton = {
        let img = UIImage(named: "info-circle")!
        let button = UIButton()
        button.setImage(img, for: .normal)
        return button
    }()

    init(viewModel: MainPageViewModeling) {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

private extension MainPageVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        versionLbl.accessibilityIdentifier = Metrics.versionIdentifier
        buildLbl.accessibilityIdentifier = Metrics.buildIdentifier
        welcomeLbl.accessibilityIdentifier = Metrics.welcomeTextIdentifier
        descriptionLbl.accessibilityIdentifier = Metrics.descriptionTextIdentifier
        logoImgView.accessibilityIdentifier = Metrics.logoIdentifier
        sampleAppImgView.accessibilityIdentifier = Metrics.sampleAppImageIdentifier
        aboutBtn.accessibilityIdentifier = Metrics.aboutBarButtonIdentifier
        exploreAPIBtn.accessibilityIdentifier = Metrics.exploreButtonIdentifier
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        view.addSubview(logoImgView)
        view.addSubview(aboutBtn)
        view.addSubview(welcomeLbl)
        view.addSubview(sampleAppImgView)
        view.addSubview(descriptionLbl)
        view.addSubview(exploreAPIBtn)
        view.addSubview(versionLbl)
        view.addSubview(buildLbl)

        logoImgView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.leading.equalToSuperview().offset(Metrics.horizontalMargin)
        }

        aboutBtn.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalMargin)
        }

        welcomeLbl.snp.makeConstraints { make in
            make.top.equalTo(logoImgView.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
        }

        sampleAppImgView.snp.makeConstraints { make in
            make.top.equalTo(welcomeLbl.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
            make.centerX.equalToSuperview()
        }

        descriptionLbl.snp.makeConstraints { make in
            make.top.equalTo(sampleAppImgView.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
        }

        exploreAPIBtn.snp.makeConstraints { make in
            make.top.equalTo(descriptionLbl.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
            make.height.equalTo(Metrics.buttonHeight)
        }

        versionLbl.snp.makeConstraints { make in
            make.top.equalTo(exploreAPIBtn.snp.bottom).offset(Metrics.verticalMargin)
            make.centerX.equalToSuperview()
        }

        buildLbl.snp.makeConstraints { make in
            make.top.equalTo(versionLbl.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        welcomeLbl.text = viewModel.outputs.welcomeText
        descriptionLbl.text = viewModel.outputs.descriptionText
        versionLbl.text = viewModel.outputs.versionText
        buildLbl.text = viewModel.outputs.buildText

        aboutBtn.tapPublisher
            .bind(to: viewModel.inputs.aboutTapped)
            .store(in: &cancellables)

        exploreAPIBtn.tapPublisher
            .bind(to: viewModel.inputs.testAPITapped)
            .store(in: &cancellables)
    }
}

//
//  MainPageVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Haiut on 07/08/2024.
//  Copyright © 2024 OpenWeb. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class MainPageVC: UIViewController {
    fileprivate struct Metrics {
        static let verticalMargin: CGFloat = 20
        static let horizontalMargin: CGFloat = 40
        static let identifier = "main_page_vc_id"
        static let logoIdentifier = "open_web_logo_id"
        static let welcomeTextIdentifier = "welcome_text_id"
        static let versionIdentifier = "version_text_id"
        static let buildIdentifier = "build_text_id"
        static let testAPIButtonIdentifier = "test_api_btn_id"
        static let aboutBarButtonIdentifier = "about_bar_btn_id"
        static let buttonHeight: CGFloat = 50
    }

    fileprivate let viewModel: MainPageViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var welcomeLbl: UILabel = {
        return UILabel()
            .numberOfLines(0)
            .textColor(ColorPalette.shared.color(type: .blackish))
            .font(FontBook.paragraphMedium)
    }()

    fileprivate lazy var versionLbl: UILabel = {
        return UILabel()
            .textColor(ColorPalette.shared.color(type: .darkGrey))
            .font(FontBook.helper)
    }()

    fileprivate lazy var buildLbl: UILabel = {
        return UILabel()
            .textColor(ColorPalette.shared.color(type: .darkGrey))
            .font(FontBook.helper)
    }()

    fileprivate lazy var testAPIBtn: UIButton = {
        return NSLocalizedString("testAPI", comment: "").blueRoundedButton
    }()

    fileprivate lazy var logoImgView: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "spot_logo")!)
            .contentMode(.scaleAspectFit)
    }()

    fileprivate lazy var aboutBarBtnItem: UIBarButtonItem = {
        return UIBarButtonItem(image: UIImage(named: "infoIcon"),
                               style: .plain,
                               target: nil,
                               action: nil)
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
        navigationItem.rightBarButtonItems = [aboutBarBtnItem]
        setupObservers()
    }
}

fileprivate extension MainPageVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        versionLbl.accessibilityIdentifier = Metrics.versionIdentifier
        buildLbl.accessibilityIdentifier = Metrics.buildIdentifier
        welcomeLbl.accessibilityIdentifier = Metrics.welcomeTextIdentifier
        logoImgView.accessibilityIdentifier = Metrics.logoIdentifier
        aboutBarBtnItem.accessibilityIdentifier = Metrics.aboutBarButtonIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        self.navigationItem.largeTitleDisplayMode = .never

        view.addSubview(versionLbl)
        view.addSubview(buildLbl)
        view.addSubview(welcomeLbl)
        view.addSubview(logoImgView)
        view.addSubview(testAPIBtn)

        versionLbl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(Metrics.verticalMargin/2)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(Metrics.horizontalMargin)
        }

        buildLbl.snp.makeConstraints { make in
            make.top.equalTo(versionLbl.snp.bottom).offset(Metrics.verticalMargin/4)
            make.leading.equalTo(versionLbl.snp.leading)
        }

        logoImgView.snp.makeConstraints { make in
            make.top.equalTo(buildLbl.snp.bottom).offset(Metrics.verticalMargin)
            make.centerX.equalToSuperview()
        }

        welcomeLbl.snp.makeConstraints { make in
            make.top.equalTo(logoImgView.snp.bottom).offset(Metrics.verticalMargin*2)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
        }

        testAPIBtn.snp.makeConstraints { make in
            make.top.equalTo(welcomeLbl.snp.bottom).offset(Metrics.verticalMargin*2)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
            make.height.equalTo(Metrics.buttonHeight)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        title = viewModel.outputs.title

        versionLbl.text = viewModel.outputs.versionText
        buildLbl.text = viewModel.outputs.buildText
        welcomeLbl.text = viewModel.outputs.welcomeText

        testAPIBtn.rx.tap
            .bind(to: viewModel.inputs.testAPITapped)
            .disposed(by: disposeBag)

        aboutBarBtnItem.rx.tap
            .bind(to: viewModel.inputs.aboutTapped)
            .disposed(by: disposeBag)
    }
}

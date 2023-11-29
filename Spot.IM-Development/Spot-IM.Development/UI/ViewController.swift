//
//  ViewController.swift
//  Spot-IM.Development
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SpotImCore
import GoogleMobileAds
import RxSwift
import SnapKit

class ViewController: UIViewController {
    fileprivate struct Metrics {
        static let identifier = "view_controller_id"
        static let testAPIBtnIdentifier = "test_api_btn_id"
        static let verticalMarginInScrollView: CGFloat = 8
    }

    @IBOutlet weak var appInfoLabel: UILabel!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var optionsScrollView: UIScrollView!

    fileprivate lazy var testAPIBtn: UIButton = {
        let btn = NSLocalizedString("TestAPI", comment: "")
            .button
            .textColor(ColorPalette.shared.color(type: .text))
            .font(FontBook.paragraph)

        return btn
    }()

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        applyAccessibility()
        setupObservers()
        fillVersionAndBuildNumber()
    }

    override func loadView() {
        super.loadView()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

fileprivate extension ViewController {
    func setupUI() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        logo.clipsToBounds = true
        logo.layer.cornerRadius = 8
        setupNavigationBar()

        optionsScrollView.addSubview(testAPIBtn)
        testAPIBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(optionsScrollView.contentLayoutGuide).offset(Metrics.verticalMarginInScrollView)
            make.bottom.lessThanOrEqualTo(optionsScrollView.contentLayoutGuide).offset(-Metrics.verticalMarginInScrollView)
        }
    }

   func setupNavigationBar() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = ColorPalette.shared.color(type: .text)
        navigationController?.navigationBar.barTintColor = ColorPalette.shared.color(type: .white)
    }

    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        testAPIBtn.accessibilityIdentifier = Metrics.testAPIBtnIdentifier
    }

    func setupObservers() {
        // Kept this code as this is a good infra for if we will have text fields in this screen
        let keyboardShowHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .map { notification -> CGFloat in
                // swiftlint:disable line_length
                let height = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.height
                // swiftlint:enable line_length
                return height ?? 0
            }

        let keyboardHideHeight = NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }

        let keyboardHeight = Observable.from([keyboardShowHeight, keyboardHideHeight])
            .merge()

        keyboardHeight
            .subscribe(onNext: { [weak self] height in
                guard let self = self else { return }
                self.optionsScrollView.contentOffset = CGPoint(x: 0, y: height/2)
            })
            .disposed(by: disposeBag)

        testAPIBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let testAPIVC = TestAPIVC()
                self.navigationController?.pushViewController(testAPIVC, animated: true)
            })
            .disposed(by: disposeBag)

    }

    func fillVersionAndBuildNumber() {
        var resultString = ""
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            resultString = "Version: \(version)\n"
        }
        if let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            resultString.append("Build: \(buildNumber)")
        }
        appInfoLabel.text = resultString
    }
}

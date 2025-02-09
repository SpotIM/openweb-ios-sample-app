//
//  SwitchSetting.swift
//  OpenWeb-Development
//
//  Created by Revital Pisman on 18/12/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SwitchSetting: UIView {

    private struct Metrics {
        static let verticalOffset: CGFloat = 20
        static let horizontalOffset: CGFloat = 10
        static let switchMinWidth: CGFloat = 50
        static let titleNumberOfLines: Int = 2
    }

    private let title: String
    private let initialIsOn: Bool

    fileprivate lazy var settingTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.paragraph)
            .numberOfLines(Metrics.titleNumberOfLines)
            .lineBreakMode(.byWordWrapping)
    }()

    fileprivate lazy var switchSetting: UISwitch = {
        let aSwitch = UISwitch()
        aSwitch.setOn(initialIsOn, animated: false)

        return aSwitch
    }()

    init(title: String, accessibilityPrefixId: String, isOn: Bool = false) {
        self.title = title
        self.initialIsOn = isOn
        super.init(frame: .zero)

        setupViews()
        applyAccessibility(prefixId: accessibilityPrefixId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension SwitchSetting {
    func applyAccessibility(prefixId: String) {
        settingTitleLbl.accessibilityIdentifier = prefixId + "_label_id"
        switchSetting.accessibilityIdentifier = prefixId + "_switch_id"
    }

    func setupViews() {
        self.addSubview(settingTitleLbl)
        settingTitleLbl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
        }

        self.addSubview(switchSetting)
        switchSetting.snp.makeConstraints { make in
            make.centerY.equalTo(settingTitleLbl)
            make.leading.greaterThanOrEqualTo(settingTitleLbl.snp.trailing).offset(Metrics.verticalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.verticalOffset)
            make.width.greaterThanOrEqualTo(Metrics.switchMinWidth)
        }
    }
}

extension Reactive where Base: SwitchSetting {

    var isOn: ControlProperty<Bool> {
        return value
    }

    private var value: ControlProperty<Bool> {
        return base.switchSetting.rx.controlProperty(editingEvents: .valueChanged) { switchSetting in
            switchSetting.isOn
        } setter: { switchSetting, value in
            switchSetting.isOn = value
        }
    }
}

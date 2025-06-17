//
//  PickerSetting.swift
//  OpenWeb-Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Combine
import UIKit

class PickerSetting: UIView {

    private struct Metrics {
        static let horizontalOffset: CGFloat = 10
        static let pickerMaxWidth: CGFloat = 220
        static let titleNumberOfLines: Int = 2
    }

    private let title: String

    fileprivate lazy var pickerTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.paragraph)
            .numberOfLines(Metrics.titleNumberOfLines)
            .lineBreakMode(.byWordWrapping)
    }()

    private(set) lazy var pickerControl: UIPickerView = {
        return UIPickerView()
    }()

    init(title: String, accessibilityPrefixId: String, items: [String]? = nil) {
        self.title = title
        super.init(frame: .zero)
        setupViews()
        applyAccessibility(prefixId: accessibilityPrefixId)

        if let items {
            pickerControl.publisher.itemTitles = items
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension PickerSetting {
    func applyAccessibility(prefixId: String) {
        pickerTitleLbl.accessibilityIdentifier = prefixId + "_label_id"
        pickerControl.accessibilityIdentifier = prefixId + "_picker_id"
    }

    @objc func setupViews() {
        self.addSubview(pickerControl)
        self.addSubview(pickerTitleLbl)

        pickerTitleLbl.snp.makeConstraints { make in
            make.centerY.equalTo(pickerControl)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
        }

        pickerControl.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualTo(pickerTitleLbl.snp.trailing).offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.width.lessThanOrEqualTo(Metrics.pickerMaxWidth)
        }
    }
}

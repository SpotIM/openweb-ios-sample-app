//
//  PickerSetting.swift
//  Spot-IM.Development
//
//  Created by Refael Sommer on 16/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PickerSetting: UIView {

    fileprivate struct Metrics {
        static let titleFontSize: CGFloat = 20
        static let horizontalOffset: CGFloat = 10
        static let pickerMaxWidth: CGFloat = 220
        static let titleNumberOfLines: Int = 2
    }

    fileprivate let title: String
    fileprivate let items = BehaviorSubject<[String]>(value: [])
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var pickerTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.paragraph)
            .numberOfLines(Metrics.titleNumberOfLines)
            .lineBreakMode(.byWordWrapping)
    }()

    fileprivate lazy var pickerControl: UIPickerView = {
        return UIPickerView()
    }()

    init(title: String, accessibilityPrefixId: String, items: [String]? = nil) {
        self.title = title
        if let items = items {
            self.items.onNext(items)
        }
        super.init(frame: .zero)

        setupViews()
        setupObservers()
        applyAccessibility(prefixId: accessibilityPrefixId)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension PickerSetting {
    func applyAccessibility(prefixId: String) {
        pickerTitleLbl.accessibilityIdentifier = prefixId + "_label_id"
        pickerControl.accessibilityIdentifier = prefixId + "_picker_id"
    }

    func setupViews() {
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

    func setupObservers() {
        items
            .skip(1) // Skip initialize BehaviorSubject value
            .take(1) // Take first value after initialize
            .bind(to: pickerControl.rx.itemTitles) { (_, element) in
                return element
            }
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: PickerSetting {
    var text: Binder<String?> {
        return Binder(self.base.pickerTitleLbl) { label, text in
            label.text = text
        }
    }

    var selectedPickerIndex: ControlEvent<(row: Int, component: Int)> {
        return value
    }

    fileprivate var value: ControlEvent<(row: Int, component: Int)> {
        return base.pickerControl.rx.itemSelected
    }

    var setSelectedPickerIndex: Binder<(row: Int, component: Int)> {
        return Binder(self.base.pickerControl) { picker, indexPath in
            picker.selectRow(indexPath.row, inComponent: indexPath.component, animated: true)
        }
    }

    var setPickerTitles: BehaviorSubject<[String]> {
        return base.items
    }
}

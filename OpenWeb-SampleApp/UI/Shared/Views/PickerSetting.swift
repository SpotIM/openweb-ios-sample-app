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

    @Published var selectedPickerIndexPath: (row: Int, component: Int) = (0, 0)
    @Published var pickerTitles: [String] = []

    private struct Metrics {
        static let horizontalOffset: CGFloat = 10
        static let pickerMaxWidth: CGFloat = 220
        static let titleNumberOfLines: Int = 2
    }

    private let title: String
    private var cancellables: Set<AnyCancellable> = []

    fileprivate lazy var pickerTitleLbl: UILabel = {
        return title
            .label
            .font(FontBook.paragraph)
            .numberOfLines(Metrics.titleNumberOfLines)
            .lineBreakMode(.byWordWrapping)
    }()

    private(set) lazy var pickerControl: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()

    init(title: String, accessibilityPrefixId: String, items: [String]? = nil) {
        self.title = title
        if let items {
            pickerTitles = items
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

private extension PickerSetting {
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
        $pickerTitles
            .sink { [weak self] _ in
                self?.pickerControl.reloadAllComponents()
            }
            .store(in: &cancellables)

        $selectedPickerIndexPath
            .sink(receiveValue: { [weak self] indexPath in
                self?.pickerControl.selectRow(indexPath.row, inComponent: indexPath.component, animated: true)
            })
            .store(in: &cancellables)
    }
}

extension PickerSetting: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerTitles.count
    }
}

extension PickerSetting: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedPickerIndexPath = (row: row, component: component)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerTitles[row]
    }
}

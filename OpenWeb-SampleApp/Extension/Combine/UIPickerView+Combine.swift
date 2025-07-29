//
//  UIPickerView+Combine.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 19/02/2025.
//

import UIKit
import Combine
import ObjectiveC.runtime

extension UIPickerView {
    var publisher: PickerPublisher {
        get {
            if let existing: PickerPublisher = getObjectiveCAssociatedObject(key: &AssociatedKeys.pickerPublisher) {
                return existing
            } else {
                let newPublisher = PickerPublisher()
                self.publisher = newPublisher
                return newPublisher
            }
        }
        set {
            newValue.pickerView = self
            self.delegate = newValue
            self.dataSource = newValue
            setObjectiveCAssociatedObject(key: &AssociatedKeys.pickerPublisher, value: newValue)
        }
    }

    class PickerPublisher: NSObject, ObservableObject, UIPickerViewDataSource, UIPickerViewDelegate {
        @Published var itemTitles: [String] = []
        @Published var selectedIndexPath: (row: Int, component: Int) = (0, 0)

        fileprivate weak var pickerView: UIPickerView?
        private var cancellables = Set<AnyCancellable>()

        override init() {
            super.init()

            $itemTitles
                .sink { [weak self] _ in
                    self?.pickerView?.reloadAllComponents()
                }
                .store(in: &cancellables)

            // When selectedIndexPath changes, select that row in the picker.
            $selectedIndexPath
                .sink { [weak self] selection in
                    self?.pickerView?.selectRow(selection.row, inComponent: selection.component, animated: false)
                }
                .store(in: &cancellables)
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            itemTitles.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            itemTitles[row]
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            selectedIndexPath = (row, component)
        }
    }

    private struct AssociatedKeys {
        static var pickerPublisher = "UIPickerView_PickerPublisher"
    }
}

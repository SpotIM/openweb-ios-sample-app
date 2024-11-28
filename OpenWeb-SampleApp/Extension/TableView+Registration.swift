//
//  TableView+Registration.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 23/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

private struct AssociatedCells {
    static var registeredCellsIdentifiers = "OWSampleAppRegisteredCellsIdentifiers"
}

extension UITableView {
    func dequeueReusableCellAndReigsterIfNeeded<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
        registerIfNeeded(cellClass: cellClass)
        // swiftlint:disable force_cast
        let cell = self.dequeueReusableCell(withIdentifier: cellClass.identifierName, for: indexPath) as! T
        // swiftlint:enable force_case
        return cell
    }

    func register<T: UITableViewCell>(cellClass: T.Type = T.self) {
        let bundle = Bundle(for: cellClass.self)
        if bundle.path(forResource: cellClass.identifierName, ofType: "nib") != nil {
            let nib = UINib(nibName: cellClass.identifierName, bundle: bundle)
            register(nib, forCellReuseIdentifier: cellClass.identifierName)
        } else {
            register(cellClass.self, forCellReuseIdentifier: cellClass.identifierName)
        }
    }
}

private extension UITableView {
    func registerIfNeeded<T: UITableViewCell>(cellClass: T.Type) {
        if registeredCellsIdentifiers.contains(cellClass.identifierName) {
            return
        }
        registeredCellsIdentifiers.insert(cellClass.identifierName)
        self.register(cellClass: cellClass)
    }

    var registeredCellsIdentifiers: Set<String> {
        get {
            return withUnsafePointer(to: &AssociatedCells.registeredCellsIdentifiers) {
                return objc_getAssociatedObject(self, $0) as? Set<String>
            } ?? Set<String>()
        }
        set {
            withUnsafePointer(to: &AssociatedCells.registeredCellsIdentifiers) {
                objc_setAssociatedObject(self, $0, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

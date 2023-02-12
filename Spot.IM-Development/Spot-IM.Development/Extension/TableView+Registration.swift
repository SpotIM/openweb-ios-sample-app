//
//  TableView+Registration.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 23/08/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
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

fileprivate extension UITableView {
    func registerIfNeeded<T: UITableViewCell>(cellClass: T.Type) {
        if registeredCellsIdentifiers.contains(cellClass.identifierName) {
            return
        }
        registeredCellsIdentifiers.insert(cellClass.identifierName)
        self.register(cellClass: cellClass)
    }

    var registeredCellsIdentifiers: Set<String> {
        get {
            // Check if it was already set
            // swiftlint:disable line_length
            if let registered = objc_getAssociatedObject(self, &AssociatedCells.registeredCellsIdentifiers) as? Set<String> {
                // swiftlint:enable line_length
                return registered
            }

            // Create set
            let registered = Set<String>()
            return registered
        }
        set {
            objc_setAssociatedObject(self, &AssociatedCells.registeredCellsIdentifiers,
                                       newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

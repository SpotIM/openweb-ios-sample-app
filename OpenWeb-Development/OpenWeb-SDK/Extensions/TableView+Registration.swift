//
//  TableView+Registration.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 01/02/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

private struct AssociatedCells {
    static var registeredCellsIdentifiers = "OWRegisteredCellsIdentifiers"
}

extension UITableView {
    func dequeueReusableCellAndReigsterIfNeeded<T: UITableViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
        registerIfNeeded(cellClass: cellClass)
        let cell = self.dequeueReusableCell(withIdentifier: cellClass.identifierName, for: indexPath) as! T // swiftlint:disable:this force_cast
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
            return self.getObjectiveCAssociatedObject(key: &AssociatedCells.registeredCellsIdentifiers) ?? Set<String>()
        }
        set {
            setObjectiveCAssociatedObject(key: &AssociatedCells.registeredCellsIdentifiers, value: newValue)
       }
    }
}

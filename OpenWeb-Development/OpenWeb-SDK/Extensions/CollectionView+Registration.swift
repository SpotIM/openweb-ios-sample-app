//
//  CollectionView+Registration.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

import UIKit

private struct AssociatedCells {
    static var registeredCellsIdentifiers = "OWSampleAppRegisteredCellsIdentifiers"
}

extension UICollectionView {
    func dequeueReusableCellAndReigsterIfNeeded<T: UICollectionViewCell>(cellClass: T.Type, for indexPath: IndexPath) -> T {
        registerIfNeeded(cellClass: cellClass)
        // swiftlint:disable force_cast
        let cell = self.dequeueReusableCell(withReuseIdentifier: cellClass.identifierName, for: indexPath) as! T
        // swiftlint:enable force_case
        return cell
    }

    func register<T: UICollectionViewCell>(cellClass: T.Type = T.self) {
        let bundle = Bundle(for: cellClass.self)
        if bundle.path(forResource: cellClass.identifierName, ofType: "nib") != nil {
            let nib = UINib(nibName: cellClass.identifierName, bundle: bundle)
            register(nib, forCellWithReuseIdentifier: cellClass.identifierName)
        } else {
            register(cellClass.self, forCellWithReuseIdentifier: cellClass.identifierName)
        }
    }
}

private extension UICollectionView {
    func registerIfNeeded<T: UICollectionViewCell>(cellClass: T.Type) {
        if registeredCellsIdentifiers.contains(cellClass.identifierName) {
            return
        }
        registeredCellsIdentifiers.insert(cellClass.identifierName)
        self.register(cellClass: cellClass)
    }

    var registeredCellsIdentifiers: Set<String> {
        get {
            return self.getObjectiveCAssociatedObject(key: &AssociatedCells.registeredCellsIdentifiers) ?? Set<String>()
        } set {
            self.setObjectiveCAssociatedObject(key: &AssociatedCells.registeredCellsIdentifiers, value: newValue)
        }
    }
}

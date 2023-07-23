//
//  CollectionView+Registration.swift
//  Spot-IM.Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
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

fileprivate extension UICollectionView {
    func registerIfNeeded<T: UICollectionViewCell>(cellClass: T.Type) {
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

//
//  CollectionView+Registration.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 27/06/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation

import UIKit

extension UICollectionView {
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

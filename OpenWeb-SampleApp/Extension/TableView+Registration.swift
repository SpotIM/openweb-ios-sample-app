//
//  TableView+Registration.swift
//  OpenWeb-Development
//
//  Created by Alon Haiut on 23/08/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import UIKit

extension UITableView {
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

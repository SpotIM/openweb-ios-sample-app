//
//  Reusable+IndentifierName.swift
//  OpenWebSDK
//
//  Created by Alon Haiut on 01/02/2022.
//  Copyright © 2022 OpenWeb. All rights reserved.
//

import Foundation
import UIKit

protocol IdentifierCell {
    static var identifierName: String { get }
}

extension IdentifierCell where Self: UIView {
    static var identifierName: String {
        return String(describing: self)
    }
}

extension UITableViewCell: IdentifierCell {}
extension UICollectionReusableView: IdentifierCell {}

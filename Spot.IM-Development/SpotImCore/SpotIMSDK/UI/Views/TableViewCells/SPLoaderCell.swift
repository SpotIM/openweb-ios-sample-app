//
//  SPLoaderCell.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 26/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation
import UIKit

final class SPLoaderCell: SPBaseTableViewCell {

    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    private func setup() {
        contentView.addSubview(activityIndicator)

        activityIndicator.startAnimating()
        activityIndicator.contentMode = .center

        activityIndicator.layout {
            $0.top.equal(to: contentView.topAnchor)
            $0.bottom.equal(to: contentView.bottomAnchor)
            $0.leading.equal(to: contentView.leadingAnchor)
            $0.trailing.equal(to: contentView.trailingAnchor)
            $0.height.equal(to: Theme.loaderHeight)
        }
    }

    public func startAnimating() {
        activityIndicator.startAnimating()
    }
}

extension SPLoaderCell {
    enum Theme {
        static let loaderHeight: CGFloat = 50.0
    }
}

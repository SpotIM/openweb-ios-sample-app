//
//  SPBaseTableViewCell.swift
//  Spot.IM-Core
//
//  Created by Eugene on 9/6/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

class SPBaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        semanticContentAttribute = LocalizationManager.currentLanguage?.customSemanticAttribute
        ?? semanticContentAttribute

        selectionStyle = .none
        contentView.backgroundColor = .spBackground0
    }

    @available(*,
    unavailable,
    message: "Loading this cell from a nib is unsupported in favor of initializer dependency injection."
    )
    required
    public init?(coder aDecoder: NSCoder) {
        fatalError("Loading this cell from a nib is unsupported in favor of initializer dependency injection.")
    }
}

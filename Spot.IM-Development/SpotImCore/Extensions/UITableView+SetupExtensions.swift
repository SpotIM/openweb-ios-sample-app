//
//  UITableView+SetupExtensions.swift
//  Spot.IM-Core
//
//  Created by Andriy Fedin on 16/10/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

typealias SPConversationCompatible = UIViewController & UITableViewDelegate & UITableViewDataSource

internal extension UITableView {
    func setupForConversation(with controller: SPConversationCompatible) {
        backgroundColor = .spBackground0
        separatorStyle = .none

        register(SPReplyCell.self, forCellReuseIdentifier: String(describing: SPReplyCell.self))
        register(SPCommentCell.self, forCellReuseIdentifier: String(describing: SPCommentCell.self))
        register(SPLoaderCell.self, forCellReuseIdentifier: String(describing: SPLoaderCell.self))
        register(SPAdBannerCell.self, forCellReuseIdentifier: String(describing: SPAdBannerCell.self))
        register(
            SPConversationSectionHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: String(describing: SPConversationSectionHeaderFooterView.self)
        )
        dataSource = controller
        delegate = controller
    }
}

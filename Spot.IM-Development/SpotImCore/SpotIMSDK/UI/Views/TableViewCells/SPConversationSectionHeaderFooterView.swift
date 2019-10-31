//
//  SPConversationSectionHeaderFooterView.swift
//  Spot.IM-Core
//
//  Created by Eugene on 8/2/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit

final class SPConversationSectionHeaderFooterView: UITableViewHeaderFooterView {

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        cellInitialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func cellInitialSetup() {
        backgroundView = UIView(frame: self.bounds)
        tintColor = .clear
        backgroundView?.backgroundColor = .iceBlue
    }

}

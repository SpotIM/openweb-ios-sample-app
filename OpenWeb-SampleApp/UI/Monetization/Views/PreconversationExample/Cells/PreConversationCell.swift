//
//  PreConversationCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import Foundation
import UIKit

class PreConversationCell: UITableViewCell {
    private struct Metrics {
        static let horizontalMargin: CGFloat = 20
    }
    
    static let identifier = "PreConversationCell"
    
    func configure(with preConversationView: UIView?) {
        guard let preConversationView else { return }
        contentView.addSubview(preConversationView)
        preConversationView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.horizontalMargin)
        }
    }
}

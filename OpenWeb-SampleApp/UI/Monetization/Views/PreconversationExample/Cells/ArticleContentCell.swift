//
//  ArticleContentCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import UIKit

class ArticleContentCell: UITableViewCell {
    private struct Metrics {
        static let horizontalMargin: CGFloat = 20
    }
    
    static let identifier = "ArticleContentCell"
    
    private lazy var lblArticleDescription: UILabel = {
        let txt = NSLocalizedString("MockArticleDescription", comment: "")

        return txt
            .label
            .numberOfLines(0)
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .text))
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(lblArticleDescription)
        lblArticleDescription.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.horizontalMargin)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

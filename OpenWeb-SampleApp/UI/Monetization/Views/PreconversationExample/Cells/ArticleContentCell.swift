//
//  ArticleContentCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import UIKit

class ArticleContentCell: UITableViewCell {
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
            make.edges.equalToSuperview()
        }
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ArticleContentCell {
    func setupViews() {
        selectionStyle = .none
        self.backgroundColor = .clear
    }
}

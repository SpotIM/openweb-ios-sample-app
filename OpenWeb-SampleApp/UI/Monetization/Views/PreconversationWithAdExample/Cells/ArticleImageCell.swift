//
//  ArticleImageCell.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 16/12/2024.
//

import Foundation
import UIKit

class ArticleImageCell: UITableViewCell {
    static let identifier = "ArticleImageCell"

    private struct Metrics {
        static let articleImageRatio: CGFloat = 2 / 3 // swiftlint:disable:this no_magic_numbers
        static let articelImageViewCornerRadius: CGFloat = 10
        static let verticalPadding: CGFloat = 40
    }

    private lazy var imgViewArticle: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "general_placeholder")!)
            .contentMode(.scaleAspectFit)
            .corner(radius: Metrics.articelImageViewCornerRadius)
    }()

    func configure(with imageURL: URL?) {
        guard let imageURL else { return }
        imgViewArticle.image(from: imageURL)
    }

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgViewArticle)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ArticleImageCell {
    @objc func setupViews() {
        imgViewArticle.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.verticalPadding)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(Metrics.articleImageRatio)
            make.height.equalTo(imgViewArticle.snp.width)
        }
        selectionStyle = .none
        self.backgroundColor = .clear
    }
}

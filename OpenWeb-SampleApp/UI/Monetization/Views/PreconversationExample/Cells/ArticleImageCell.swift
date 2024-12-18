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
        static let verticalMargin: CGFloat = 40
        static let articleHeight: CGFloat = 1.2 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2 / 3
        static let horizontalMargin: CGFloat = 20
        static let articelImageViewCornerRadius: CGFloat = 10
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgViewArticle)
        imgViewArticle.snp.makeConstraints { make in
            make.center.bottom.equalToSuperview()
            make.width.equalTo(imgViewArticle.snp.height)
            make.width.equalToSuperview().multipliedBy(Metrics.articleImageRatio)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  ArticleTableViewCell.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 14/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import Cards
import Kingfisher

protocol ArticleTableViewCellDelegate: class {
    func articleCellTapped(cell:ArticleTableViewCell, withPost: Post?)
}

class ArticleTableViewCell : UITableViewCell {
    
    weak var delegate :ArticleTableViewCellDelegate?
    
    var post : Post? {
        didSet {
            guard let extract = post?.extractData, let publishedAt = post?.publishedAt  else {
                return
            }
     
            card.category = self.formattedDate(publishedAt: publishedAt)
            card.title = extract.title.truncated(limit: 60)
            card.subtitle = extract.description.truncated(limit: 100)
            
            let url = URL(string: extract.thumbnailUrl)
            let processor = OverlayImageProcessor(overlay: .black)
            
            self.card.backgroundIV.kf.indicatorType = .activity
            self.card.backgroundIV.kf.setImage(with: url, placeholder: nil, options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .forceRefresh
            ])
            
            card.delegate = self
        }
    }
    
    override func prepareForReuse() {
        card.title = ""
        card.backgroundIV.kf.cancelDownloadTask()
        card.backgroundIV.kf.setImage(with: nil)
    }
    
    
    private let card : CardArticle = {
        let card = CardArticle(frame: CGRect(x: 10, y: 0, width: 200 , height: 240))
        
        card.backgroundColor = UIColor(red: 0, green: 94/255, blue: 112/255, alpha: 1)
        card.textColor = UIColor.white
        card.hasParallax = true
        
        return card
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func formattedDate(publishedAt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:publishedAt)!
        return date.timeAgo()
    }
    
    private func setup() {
        self.setupCard()
    }
    
    private func setupCard() {
        addSubview(card)
        card.snp_makeConstraints {
            $0.centerX.equalTo(self)
            $0.top.equalTo(self).offset(20)
            $0.bottom.equalTo(self).offset(-20)
            $0.height.equalTo(card.snp.width).multipliedBy(1.2)
            $0.width.equalTo(self).multipliedBy(0.8)
        }
        card.delegate = self
    }
    
}

extension ArticleTableViewCell : CardDelegate {
    func cardDidTapInside(card: Card) {
        self.delegate?.articleCellTapped(cell: self, withPost: self.post)
    }
}

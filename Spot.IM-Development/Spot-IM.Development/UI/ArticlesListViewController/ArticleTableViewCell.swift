//
//  ArticleTableViewCell.swift
//  Spot-IM.Development
//
//  Created by Itay Dressler on 14/08/2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

protocol ArticleTableViewCellDelegate: AnyObject {
    func articleCellTapped(withPost: Post?)
}

class ArticleTableViewCell: UITableViewCell {
    
    fileprivate struct Metrics {
        static let corenerRadius: CGFloat = 15
        static let verticalOffset: CGFloat = 20
        static let horizontalOffset: CGFloat = 20
        static let aspectRatio: CGFloat = 1.2
        static let outlineColor: UIColor = .black
        static let imageOpacity: Float = 0.2
        static let outlineWidth: Float = 4.0
        static let placeholder: UIImage = UIImage(named: "general_placeholder")!
    }
    
    fileprivate var disposeBag: DisposeBag!
    
    fileprivate lazy var mainView: UIView = {
        let view = UIView()
            .corner(radius: Metrics.corenerRadius)
                
        view.addGestureRecognizer(tapGesture)
        
        view.addSubview(backgroundImageView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.lessThanOrEqualToSuperview()
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.top.equalTo(dateLabel.snp.bottom).offset(Metrics.verticalOffset/4)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
        }
        
        return view
    }()
    
    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()
    
    fileprivate lazy var backgroundImageView: UIImageView = {
        let img = UIImageView()
            .contentMode(.scaleAspectFill)
        img.image = Metrics.placeholder
        
        let opacityView = UIView()
        opacityView.layer.opacity = Metrics.imageOpacity
        opacityView.layer.backgroundColor = UIColor.black.cgColor
        
        img.addSubview(opacityView)
        opacityView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return img
    }()
    
    fileprivate lazy var dateLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.primaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .basicGrey))
        return lbl
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.secondaryHeadingBold)
            .textColor(.white)
            .numberOfLines(2)
        return lbl
    }()
    
    fileprivate lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
            .font(FontBook.paragraphBold)
            .textColor(.white)
            .numberOfLines(3)
        return lbl
    }()
        
    weak var delegate: ArticleTableViewCellDelegate?
    
    // This variable can be seen like a "configure" function in general
    var post : Post? {
        didSet {
            guard let extract = post?.extractData, let publishedAt = post?.publishedAt else {
                return
            }
            
            let dateText = self.formattedDate(publishedAt: publishedAt)
            let title = extract.title.truncated(limit: 60)
            let description = extract.description.truncated(limit: 100)
            
            dateLabel.attributedText = attributedOutlineText(dateText, color: dateLabel.textColor,
                                                             outlineColor: Metrics.outlineColor, font: dateLabel.font)
            
            titleLabel.attributedText = attributedOutlineText(title, color: titleLabel.textColor,
                                                             outlineColor: Metrics.outlineColor, font: titleLabel.font)
            
            descriptionLabel.attributedText = attributedOutlineText(description, color: descriptionLabel.textColor,
                                                             outlineColor: Metrics.outlineColor, font: descriptionLabel.font)

            if let url = URL(string: extract.thumbnailUrl) {
                backgroundImageView.image(from: url)
            }
            
            self.setupObservers()
        }
    }
    
    override func prepareForReuse() {
        backgroundImageView.image = Metrics.placeholder
        disposeBag = nil
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension ArticleTableViewCell {
    
    func attributedOutlineText(_ text: String,
                               color: UIColor,
                               outlineColor: UIColor,
                               font: UIFont) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: outlineColor,
            NSAttributedString.Key.foregroundColor: color,
            NSAttributedString.Key.strokeWidth: -Metrics.outlineWidth,
            NSAttributedString.Key.font: font
        ]
        
        return NSMutableAttributedString(string: text, attributes: attributes)
    }
    
    func formattedDate(publishedAt: String) -> String {
        guard !publishedAt.isEmpty else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:publishedAt)!
        return date.timeAgo()
    }
    
    func setupUI() {
        self.selectionStyle = .none
        
        addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalOffset)
            make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
            make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            make.height.equalTo(mainView.snp.width).multipliedBy(Metrics.aspectRatio)
        }
    }
    
    func setupObservers() {
        disposeBag = DisposeBag()
        
        tapGesture.rx.event
            .voidify()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.articleCellTapped(withPost: self.post)
            })
            .disposed(by: disposeBag)
    }
}

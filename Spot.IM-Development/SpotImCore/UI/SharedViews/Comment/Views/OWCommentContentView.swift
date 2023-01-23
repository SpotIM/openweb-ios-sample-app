//
//  OWCommentContentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWCommentContentView: UIView {
    public struct Metrics {
        static let fontSize: CGFloat = 16.0
        static let commentMediaTopPadding: CGFloat = 12.0
        static let emptyCommentMediaTopPadding: CGFloat = 10.0
    }
    
    fileprivate lazy var textLabel: OWCommentTextView = {
       return OWCommentTextView()
            .numberOfLines(0)
//            .font(.preferred(style: .regular, of: Metrics.fontSize))
    }()
    
    fileprivate lazy var mediaView: CommentMediaView = {
        return CommentMediaView()
    }()
    
    fileprivate var viewModel: OWCommentContentViewModeling!
    fileprivate var disposeBag: DisposeBag!

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func configure(with viewModel: OWCommentContentViewModeling) {
        self.viewModel = viewModel
        textLabel.configure(with: viewModel.outputs.collapsableLabelViewModel)
        self.disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWCommentContentView {
    func setupViews() {
        self.addSubviews(textLabel, mediaView)
        
        textLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        mediaView.OWSnp.makeConstraints { make in
            make.top.equalTo(textLabel.OWSnp.bottom).offset(Metrics.emptyCommentMediaTopPadding)
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.bottom.equalToSuperview()
            make.size.equalTo(0)
        }
    }
    
    func setupObservers() {
//        viewModel.inputs.commentTextLabelWidth.onNext(textLabel.frame.width) // TODO via rx on the label width?
        
        viewModel.outputs.image
            .subscribe(onNext: { [weak self] imageType in
                guard let self = self,
                      case .custom(let url) = imageType
                else { return }
                
                self.mediaView.configureMedia(imageUrl: url, gifUrl: nil)
            })
            .disposed(by: disposeBag)
                
        viewModel.outputs.gifUrl
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.mediaView.configureMedia(imageUrl: nil, gifUrl: url)
            })
            .disposed(by: disposeBag)
        
        viewModel.outputs.mediaSize
            .subscribe(onNext: { [weak self] size in
                guard let self = self else { return }
                self.mediaView.OWSnp.updateConstraints { make in
                    make.size.equalTo(size)
                    make.top.equalTo(self.textLabel.OWSnp.bottom).offset(
                        size != CGSize.zero ? Metrics.commentMediaTopPadding : Metrics.emptyCommentMediaTopPadding
                    )
                }
            })
            .disposed(by: disposeBag)
    }
}

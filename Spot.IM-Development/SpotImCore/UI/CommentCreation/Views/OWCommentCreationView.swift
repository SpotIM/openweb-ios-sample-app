//
//  OWCommentCreationView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_view_id"
    }
    
    // TODO: this label is only to show the origin comment user when creating a reply. Should be removed
    fileprivate lazy var replyToLabel: UILabel = {
        return UILabel()
            .textColor(.black)
    }()
    
    fileprivate let viewModel: OWCommentCreationViewViewModeling
    fileprivate let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(viewModel: OWCommentCreationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
        applyAccessibility()
    }
    
    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

fileprivate extension OWCommentCreationView {
    func setupViews() {
        self.useAsThemeStyleInjector()
        
        // TODO: Remove the ugly blue when actually starting to work on the UI, this is only for integration purposes at the moment
        self.backgroundColor = .blue
        self.addSubviews(replyToLabel)
        replyToLabel.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.outputs.replyToComment
            .unwrap()
            .map { comment in
                return "Reply To: \(comment.userId)"
            }
            .bind(to: replyToLabel.rx.text)
            .disposed(by: disposeBag)
    }
}

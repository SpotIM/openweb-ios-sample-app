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
    
    fileprivate lazy var label: UILabel = {
        return UILabel()
            .text("AAA")
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
        self.addSubviews(label)
        label.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupObservers() {
        viewModel.outputs.replyToComment
            .map { comment in
                print("NOGAH: userID \(comment?.userId)")
                return comment?.userId
            }
            .unwrap()
            .bind(to: label.rx.text)
            .disposed(by: disposeBag)
    }
}

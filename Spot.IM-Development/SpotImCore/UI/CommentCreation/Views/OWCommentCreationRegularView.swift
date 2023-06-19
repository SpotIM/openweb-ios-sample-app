//
//  OWCommentCreationRegularView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/06/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationRegularView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_regular_view_id"
    }

    // TODO: this label is only to show the origin comment user when creating a reply. Should be removed
    fileprivate lazy var replyToLabel: UILabel = {
        let text: String? = {
            switch viewModel.outputs.commentType {
            case .comment:
                return nil
            case .replyToComment(let originComment):
                return "Reply to user: \(originComment.userId ?? "missing userId")"
            }
        }()
        return UILabel()
            .textColor(.black)
            .text(text)
    }()

    fileprivate let viewModel: OWCommentCreationRegularViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationRegularViewViewModeling) {
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

fileprivate extension OWCommentCreationRegularView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        // TODO: Remove the ugly red when actually starting to work on the UI, this is only for integration purposes at the moment
        self.backgroundColor = .red
        self.addSubviews(replyToLabel)
        replyToLabel.OWSnp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    func setupObservers() {

    }
}

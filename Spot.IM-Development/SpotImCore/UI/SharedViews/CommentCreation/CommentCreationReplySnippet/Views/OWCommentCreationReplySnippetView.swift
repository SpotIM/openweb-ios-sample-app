//
//  OWCommentCreationReplySnippetView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 16/07/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift

class OWCommentCreationReplySnippetView: UIView {
    fileprivate struct Metrics {
        static let identifier = "comment_cretion_reply_snippet_id"
        static let labelIdentifier = "comment_cretion_reply_snippet_label_id"

        static let horizontalOffset: CGFloat = 16.0
        static let bottomSpacing: CGFloat = 12.0
        static let replySnippetNumberOfLines: Int = 2
    }

    fileprivate lazy var replySnippetLabel: UILabel = {
        return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteText))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .numberOfLines(Metrics.replySnippetNumberOfLines)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var bottomSeparatorView: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .separatorColor1,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate let disposeBag = DisposeBag()
    fileprivate let viewModel: OWCommentCreationReplySnippetViewModeling

    init(with viewModel: OWCommentCreationReplySnippetViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)

        setupUI()
        setupObservers()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWCommentCreationReplySnippetView {
    func setupUI() {
        self.enforceSemanticAttribute()

        addSubview(replySnippetLabel)
        replySnippetLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
        }

        addSubview(bottomSeparatorView)
        bottomSeparatorView.OWSnp.makeConstraints { make in
            make.top.equalTo(replySnippetLabel.OWSnp.bottom).offset(Metrics.bottomSpacing)
            make.height.equalTo(1)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.replySnippetLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
                self.bottomSeparatorView.backgroundColor = OWColorPalette.shared.color(type: .separatorColor1, themeStyle: currentStyle)
            }).disposed(by: disposeBag)

        viewModel.outputs.replySnippetText
            .bind(to: replySnippetLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.showSeparator
            .map { !$0 }
            .bind(to: bottomSeparatorView.rx.isHidden)
            .disposed(by: disposeBag)

    }

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
        self.replySnippetLabel.accessibilityIdentifier = Metrics.labelIdentifier
    }
}

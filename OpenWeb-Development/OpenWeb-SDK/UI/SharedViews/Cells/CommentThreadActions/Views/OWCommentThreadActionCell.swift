//
//  OWCommentThreadCollapseCell.swift
//  OpenWebSDK
//
//  Created by Alon Shprung on 29/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentThreadActionCell: UITableViewCell {
    fileprivate struct Metrics {
        static let depthOffset: CGFloat = 23
    }

    fileprivate lazy var commentThreadActionsView: OWCommentThreadActionsView = {
       return OWCommentThreadActionsView()
    }()

    fileprivate var viewModel: OWCommentThreadActionsCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentThreadActionsCellViewModeling else { return }
        self.disposeBag = DisposeBag()
        self.viewModel = vm

        commentThreadActionsView.configure(with: self.viewModel.outputs.commentActionsVM)

        let depth = min(self.viewModel.outputs.depth, OWCommentCell.ExternalMetrics.maxDepth)
        commentThreadActionsView.OWSnp.updateConstraints { make in
            make.leading.equalToSuperview().offset(CGFloat(depth) * Metrics.depthOffset)
        }

        self.setupObservers()
        self.viewModel.inputs.triggerUpdateActionType.onNext()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.commentThreadActionsView.prepareForReuse()
    }
}

fileprivate extension OWCommentThreadActionCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2,
                                                           themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        self.contentView.addSubviews(commentThreadActionsView)
        self.selectionStyle = .none

        commentThreadActionsView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)
    }
}

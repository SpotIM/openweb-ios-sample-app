//
//  OWCommentCell.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/12/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommentCell: UITableViewCell {
    fileprivate struct Metrics {
        static let horizontalOffset: CGFloat = 16
        static let depthOffset: CGFloat = 23
    }

    fileprivate lazy var commentView: OWCommentView = {
       return OWCommentView()
    }()

    fileprivate var viewModel: OWCommentCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommentCellViewModeling else { return }

        self.disposeBag = DisposeBag()
        self.viewModel = vm
        self.commentView.configure(with: self.viewModel.outputs.commentVM)

        if let depth = self.viewModel.outputs.commentVM.outputs.comment.depth {
            commentView.OWSnp.updateConstraints { make in
                make.leading.equalToSuperview().offset(CGFloat(depth) * Metrics.depthOffset + Metrics.horizontalOffset)
            }
        }
        self.setupObservers()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        commentView.prepareForReuse()
    }
}

fileprivate extension OWCommentCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)
        self.contentView.addSubviews(commentView)
        self.selectionStyle = .none

        commentView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalOffset)
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

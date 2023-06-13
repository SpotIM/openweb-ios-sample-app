//
//  OWCommunityQuestionCell.swift
//  SpotImCore
//
//  Created by Revital Pisman on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommunityQuestionCell: UITableViewCell {

    fileprivate struct Metrics {
        static let edgesPadding: CGFloat = 12
        static let identifier = "community_question_cell_id"
    }

    fileprivate lazy var communityQuestionView: OWCommunityQuestionView = {
       let communityQuestionView = OWCommunityQuestionView()
        return communityQuestionView
    }()

    fileprivate var viewModel: OWCommunityQuestionCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommunityQuestionCellViewModel else { return }

        self.viewModel = vm
        disposeBag = DisposeBag()

        communityQuestionView.configure(with: self.viewModel.outputs.communityQuestionViewModel)
        self.setupObservers()
    }
}

fileprivate extension OWCommunityQuestionCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)

        self.addSubviews(communityQuestionView)
        communityQuestionView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.edgesPadding)
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

    func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}


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
    }

    fileprivate lazy var communityQuestionView: OWCommunityQuestionView = {
       let communityQuestionView = OWCommunityQuestionView()
        return communityQuestionView
    }()

    fileprivate var viewModel: OWCommunityQuestionCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommunityQuestionCellViewModel else { return }

        self.viewModel = vm
        disposeBag = DisposeBag()

        communityQuestionView.configure(with: self.viewModel.outputs.communityQuestionViewModel)
    }
}

fileprivate extension OWCommunityQuestionCell {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubviews(communityQuestionView)
        communityQuestionView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.edgesPadding)
        }
    }
}


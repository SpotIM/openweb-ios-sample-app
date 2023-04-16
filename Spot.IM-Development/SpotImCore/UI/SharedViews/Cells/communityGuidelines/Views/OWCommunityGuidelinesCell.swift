//
//  OWCommunityGuidelinesCell.swift
//  SpotImCore
//
//  Created by Revital Pisman on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommunityGuidelinesCell: UITableViewCell {

    fileprivate struct Metrics {
        static let edgesPadding: CGFloat = 12
    }

    fileprivate lazy var communityGuidelinesView: OWCommunityGuidelinesView = {
        return OWCommunityGuidelinesView()
    }()

    fileprivate var viewModel: OWCommunityGuidelinesCellViewModeling!
    fileprivate var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommunityGuidelinesCellViewModel else { return }

        self.viewModel = vm
        disposeBag = DisposeBag()

        communityGuidelinesView.configure(with: self.viewModel.outputs.communityGuidelinesViewModel)
    }
}

fileprivate extension OWCommunityGuidelinesCell {
    func setupUI() {
        self.backgroundColor = .clear

        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Metrics.edgesPadding)
        }
    }
}

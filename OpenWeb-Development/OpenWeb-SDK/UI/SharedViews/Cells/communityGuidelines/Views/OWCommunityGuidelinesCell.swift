//
//  OWCommunityGuidelinesCell.swift
//  OpenWebSDK
//
//  Created by Revital Pisman on 28/03/2023.
//  Copyright © 2023 OpenWeb. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class OWCommunityGuidelinesCell: UITableViewCell {

    private struct Metrics {
        static let edgesPadding: CGFloat = 12
        static let identifier = "community_guidelines_cell_id"
    }

    private lazy var communityGuidelinesView: OWCommunityGuidelinesView = {
        return OWCommunityGuidelinesView()
    }()

    private var viewModel: OWCommunityGuidelinesCellViewModeling!
    private var disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
        self.applyAccessibility()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configure(with viewModel: OWCellViewModel) {
        guard let vm = viewModel as? OWCommunityGuidelinesCellViewModel else { return }

        self.viewModel = vm
        disposeBag = DisposeBag()

        communityGuidelinesView.configure(with: self.viewModel.outputs.communityGuidelinesViewModel)
        self.setupObservers()
    }
}

private extension OWCommunityGuidelinesCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2,
                                                           themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        self.contentView.isUserInteractionEnabled = false

        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(Metrics.edgesPadding)
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

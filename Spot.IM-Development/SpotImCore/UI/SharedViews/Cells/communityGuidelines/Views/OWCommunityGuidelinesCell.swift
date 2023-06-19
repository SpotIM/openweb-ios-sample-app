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
        self.setupObservers()
    }
}

fileprivate extension OWCommunityGuidelinesCell {
    func setupUI() {
        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)
        self.contentView.isUserInteractionEnabled = false

        self.addSubview(communityGuidelinesView)
        communityGuidelinesView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(Metrics.edgesPadding)
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.trailing.equalTo(safeAreaLayoutGuide).inset(Metrics.edgesPadding)
            } else {
                make.leading.trailing.equalToSuperview().inset(Metrics.edgesPadding)
            }
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

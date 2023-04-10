//
//  OWPreConversationClosedPlaceholderView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 28/03/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWPreConversationClosedPlaceholderView: UIView {
    fileprivate struct Metrics {
        static let fontSize: CGFloat = 15
        static let labelLeadingOffset: CGFloat = 4
        static let iconSize: CGFloat = 24
    }

    fileprivate lazy var iconImageView: UIImageView = {
       return UIImageView(image: UIImage(spNamed: "time-icon", supportDarkMode: true))
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var label: UILabel = {
       return UILabel()
            .text(OWLocalizationManager.shared.localizedString(key: "Commenting on this article has ended"))
            .textColor(OWColorPalette.shared.color(type: .textColor3, themeStyle: .light))
            .font(OWFontBook.shared.font(style: .medium, size: Metrics.fontSize))
            .enforceSemanticAttribute()
    }()

    fileprivate let disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension OWPreConversationClosedPlaceholderView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.addSubview(iconImageView)
        iconImageView.OWSnp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.size.equalTo(Metrics.iconSize)
        }

        self.addSubview(label)
        label.OWSnp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalTo(iconImageView.OWSnp.trailing).inset(-Metrics.labelLeadingOffset)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }

                self.label.textColor = OWColorPalette.shared.color(type: .textColor3, themeStyle: currentStyle)
                self.iconImageView.image = UIImage(spNamed: "time-icon", supportDarkMode: true)
            })
            .disposed(by: disposeBag)
    }
}

//
//  OWCommunityQuestionView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift

// TODO: complete
class OWCommunityQuestionView: UIView {
    fileprivate struct Metrics {
        static let identifier = "community_question_id"
        static let fontSize: CGFloat = 15.0
        static let questionHorizontalOffset: CGFloat = 12.0
        static let questionVerticalOffset: CGFloat = 8.0
        static let containerCorderRadius: CGFloat = 8.0
    }

    fileprivate lazy var questionLabel: UILabel = {
        return UILabel()
            .font(UIFont.preferred(style: .italic, of: Metrics.fontSize))
            .textColor(OWColorPalette.shared.color(type: .foreground0Color,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
    }()

    fileprivate lazy var questionContainer: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .compactBackground, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)) // TODO: color
            .corner(radius: Metrics.containerCorderRadius)
            .border(width: 1, color: UIColor.black) // TODO: color
    }()

    fileprivate var heightConstraint: OWConstraint?
    fileprivate let viewModel: OWCommunityQuestionViewModeling
    fileprivate let disposeBag = DisposeBag()

    init(with viewModel: OWCommunityQuestionViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.accessibilityIdentifier = Metrics.identifier
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension OWCommunityQuestionView {
    func setupViews() {
        self.backgroundColor = .clear

        self.addSubview(questionContainer)
        questionContainer.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        questionContainer.addSubviews(questionLabel)
        questionLabel.OWSnp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.questionVerticalOffset)
            make.bottom.equalToSuperview().offset(-Metrics.questionVerticalOffset)
            make.leading.equalToSuperview().offset(Metrics.questionHorizontalOffset)
            make.trailing.equalToSuperview().offset(-Metrics.questionHorizontalOffset)
        }
    }

    func setupObservers() {
        let communityQuestionObservable = viewModel.outputs
                    .communityQuestionOutput
                    .observe(on: MainScheduler.instance)
                    .share(replay: 0)

        communityQuestionObservable
            .bind(to: questionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        // TODO: colors
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.questionLabel.textColor = OWColorPalette.shared.color(type: .foreground0Color,
                                                                              themeStyle: currentStyle)
                // TODO: custon UI
            }).disposed(by: disposeBag)
    }
}

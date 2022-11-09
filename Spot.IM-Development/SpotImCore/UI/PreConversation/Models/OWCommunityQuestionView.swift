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
        static let fontSize: CGFloat = 20.0
        static let questionHorizontalOffset: CGFloat = 16.0
    }
    
    fileprivate lazy var questionTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.font = UIFont.preferred(style: .bold, of: Metrics.fontSize)
        textView.textColor = OWColorPalette.shared.color(type: .foreground0Color,
                                                         themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle)
        return textView
    }()
    
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
        self.addSubviews(questionTextView)
        
        questionTextView.OWSnp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            // avoide device notch in landscape
            if #available(iOS 11.0, *) {
                make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.questionHorizontalOffset)
                make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.questionHorizontalOffset)
            } else {
                make.leading.equalToSuperview().offset(Metrics.questionHorizontalOffset)
                make.trailing.equalToSuperview().offset(-Metrics.questionHorizontalOffset)
            }
        }
    }
    
    func setupObservers() {
        viewModel.outputs
            .communityQuestionString
            .bind(to: questionTextView.rx.text)
            .disposed(by: disposeBag)
        
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.questionTextView.textColor = OWColorPalette.shared.color(type: .foreground0Color,
                                                                              themeStyle: currentStyle)
                // TODO: custon UI
            }).disposed(by: disposeBag)
    }
}

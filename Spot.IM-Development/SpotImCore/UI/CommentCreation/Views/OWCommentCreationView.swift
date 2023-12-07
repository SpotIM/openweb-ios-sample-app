//
//  OWCommentCreationView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationView: UIView, OWThemeStyleInjectorProtocol {
    fileprivate struct Metrics {
        static let identifier = "comment_creation_view_id"
    }

    fileprivate lazy var commentCreationRegularView = {
        return OWCommentCreationRegularView(viewModel: self.viewModel.outputs.commentCreationRegularViewVm)
    }()

    fileprivate lazy var commentCreationLightView = {
        return OWCommentCreationLightView(viewModel: self.viewModel.outputs.commentCreationLightViewVm)
    }()

    fileprivate lazy var commentCreationFloatingKeyboardView = {
        return OWCommentCreationFloatingKeyboardView(viewModel: self.viewModel.outputs.commentCreationFloatingKeyboardViewVm)
    }()

    fileprivate lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        return tap
    }()

    fileprivate let viewModel: OWCommentCreationViewViewModeling
    fileprivate let disposeBag = DisposeBag()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationViewViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    private func applyAccessibility() {
        self.accessibilityIdentifier = Metrics.identifier
    }
}

fileprivate extension OWCommentCreationView {
    func setupViews() {
        self.useAsThemeStyleInjector()

        self.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)

        let commentCreationView: UIView
        switch viewModel.outputs.commentCreationStyle {
        case .regular:
            self.addGestureRecognizer(tapGesture)
            commentCreationView = commentCreationRegularView
        case .light:
            self.addGestureRecognizer(tapGesture)
            commentCreationView = commentCreationLightView
        case .floatingKeyboard:
            // Intentionally not adding the `tapGesture` here, to not mess up with the bottom toolbar if such exist.
            // Should add a gesture recognizer only to the containing view above it
            commentCreationView = commentCreationFloatingKeyboardView
        }

        self.addSubview(commentCreationView)
        commentCreationView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperviewSafeArea()
        }
    }

    func setupObservers() {
        tapGesture.rx.event
            .voidify()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.endEditing(true)
            })
            .disposed(by: disposeBag)
    }
}

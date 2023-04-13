//
//  OWCommunityGuidelinesView.swift
//  SpotImCore
//
//  Created by  Nogah Melamed on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: complete
class OWCommunityGuidelinesView: UIView {
    fileprivate struct Metrics {
        static let identifier = "community_guidelines_id"
        static let containerCorderRadius: CGFloat = 8.0
        static let horizontalOffset: CGFloat = 16.0
        static let verticalOffset: CGFloat = 14.0
        static let horizontalPadding: CGFloat = 10.0
    }

    fileprivate lazy var titleTextView: UITextView = {
        let textView = UITextView()
            .backgroundColor(.clear)
            .delegate(self)
            .isEditable(false)
            .isSelectable(true)
            .isScrollEnabled(false)
            .dataDetectorTypes([.link])

        textView.text = "TEST"
        return textView
    }()

    fileprivate lazy var guidelinesContainer: UIView = {
        return UIView()
            .backgroundColor(OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: OWSharedServicesProvider.shared.themeStyleService().currentStyle))
            .corner(radius: Metrics.containerCorderRadius)
    }()

    fileprivate lazy var guidelinesIcon: UIImageView = {
        let img = UIImageView()
            .contentMode(.scaleAspectFit)
            .image(UIImage(spNamed: "guidelinesIcon", supportDarkMode: false)!)

        return img
    }()

    fileprivate var heightConstraint: OWConstraint? = nil
    fileprivate var viewModel: OWCommunityGuidelinesViewModeling!
    fileprivate var disposeBag = DisposeBag()

    init(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        setupObservers()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(frame: .zero)
    }

    // Only when using community question as a cell
    func configure(with viewModel: OWCommunityGuidelinesViewModeling) {
        self.viewModel = viewModel
        self.disposeBag = DisposeBag()
        self.setupViews()
        self.setupObservers()
    }
}

extension OWCommunityGuidelinesView {
    fileprivate func setupViews() {
        self.accessibilityIdentifier = Metrics.identifier
        self.backgroundColor = .clear
        self.isHidden = true

        if viewModel.outputs.showContainer {
            self.addSubview(guidelinesContainer)
            guidelinesContainer.OWSnp.makeConstraints { make in
                make.edges.equalToSuperview()
                heightConstraint = make.height.equalTo(0).constraint
            }

            guidelinesContainer.addSubview(guidelinesIcon)
            guidelinesIcon.OWSnp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-Metrics.verticalOffset)
                make.top.leading.equalToSuperview().offset(Metrics.horizontalOffset)
            }

            guidelinesContainer.addSubview(titleTextView)
            titleTextView.OWSnp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalTo(guidelinesIcon.OWSnp.trailing).offset(Metrics.horizontalPadding)
                make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
            }
        } else {
            self.addSubview(titleTextView)
            titleTextView.OWSnp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                // avoide device notch in landscape
                if #available(iOS 11.0, *) {
                    make.leading.equalTo(safeAreaLayoutGuide).offset(Metrics.horizontalOffset)
                    make.trailing.equalTo(safeAreaLayoutGuide).offset(-Metrics.horizontalOffset)
                } else {
                    make.leading.equalToSuperview().offset(Metrics.horizontalOffset)
                    make.trailing.equalToSuperview().offset(-Metrics.horizontalOffset)
                }
            }
        }

        titleTextView.OWSnp.makeConstraints { make in
            heightConstraint = make.height.equalTo(0).constraint
        }
    }

    fileprivate func setupObservers() {
        viewModel.outputs.shouldShowView
            .map { !$0 }
            .bind(to: self.rx.isHidden)
            .disposed(by: disposeBag)

        if let heightConstraint = heightConstraint {
            viewModel.outputs.shouldShowView
                .map { !$0 }
                .bind(to: heightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.communityGuidelinesHtmlAttributedString
            .bind(to: titleTextView.rx.attributedText)
            .disposed(by: disposeBag)

        // disable selecting text - we need it to allow click on links
        titleTextView.rx.didChangeSelection
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.titleTextView.selectedTextRange = nil
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                 guard let self = self else { return }

                self.guidelinesContainer.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor1, themeStyle: currentStyle)
                self.titleTextView.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)

                // TODO: custom UI
            }).disposed(by: disposeBag)
    }
}

extension OWCommunityGuidelinesView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        viewModel.inputs.urlClicked.onNext(URL)
        return false
    }
}

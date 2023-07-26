//
//  OWCommentContentView.swift
//  SpotImCore
//
//  Created by Alon Shprung on 07/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class OWCommentContentView: UIView {
    internal struct Metrics {
        static let commentMediaTopPadding: CGFloat = 6.0
        static let emptyCommentMediaTopPadding: CGFloat = 0
        static let paragraphLineSpacing: CGFloat = 3.5
        static let editedTopPadding: CGFloat = 4.0

        static let identifier = "comment_content_view_id"
        static let textLabelIdentifier = "comment_content_text_label_id"
        static let mediaViewIdentifier = "comment_media_view_id"
        static let editedLabelIdentifier = "comment_edited_label_id"
    }

    fileprivate lazy var textLabel: OWCommentTextLabel = {
       return OWCommentTextLabel()
            .numberOfLines(0)
            .enforceSemanticAttribute()
    }()

    fileprivate lazy var mediaView: CommentMediaView = {
        return CommentMediaView()
    }()

    fileprivate lazy var editedLabel: UILabel = {
       return UILabel()
            .font(OWFontBook.shared.font(typography: .footnoteSpecial))
            .text(OWLocalizationManager.shared.localizedString(key: "Edited"))
            .textColor(OWColorPalette.shared.color(type: .textColor2, themeStyle: .light))
            .enforceSemanticAttribute()
    }()

    fileprivate var viewModel: OWCommentContentViewModeling!
    fileprivate var disposeBag: DisposeBag!
    fileprivate var textHeightConstraint: OWConstraint?
    fileprivate var editedLabelHeightConstraint: OWConstraint?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        applyAccessibility()
    }

    func configure(with viewModel: OWCommentContentViewModeling) {
        self.viewModel = viewModel
        textLabel.configure(with: viewModel.outputs.collapsableLabelViewModel)
        self.disposeBag = DisposeBag()
        setupObservers()
    }
}

fileprivate extension OWCommentContentView {
    func setupViews() {
        self.enforceSemanticAttribute()
        self.addSubviews(textLabel, mediaView)

        textLabel.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            textHeightConstraint = make.height.equalTo(0).constraint
        }

        mediaView.OWSnp.makeConstraints { make in
            make.top.equalTo(textLabel.OWSnp.bottom).offset(Metrics.emptyCommentMediaTopPadding)
            make.trailing.lessThanOrEqualToSuperview()
            make.leading.equalToSuperview()
            make.size.equalTo(0)
        }

        self.addSubview(editedLabel)
        editedLabel.OWSnp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(mediaView.OWSnp.bottom).offset(Metrics.editedTopPadding)
            editedLabelHeightConstraint = make.height.equalTo(0).constraint
        }
    }

    func setupObservers() {
        viewModel.outputs.image
            .subscribe(onNext: { [weak self] imageType in
                guard let self = self,
                      case .custom(let url) = imageType else { return }

                self.mediaView.configureMedia(imageUrl: url, gifUrl: nil)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.gifUrl
            .subscribe(onNext: { [weak self] url in
                guard let self = self else { return }
                self.mediaView.configureMedia(imageUrl: nil, gifUrl: url)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.mediaSize
            .subscribe(onNext: { [weak self] size in
                guard let self = self else { return }
                self.mediaView.OWSnp.updateConstraints { make in
                    make.size.equalTo(size)
                    make.top.equalTo(self.textLabel.OWSnp.bottom).offset(
                        size != CGSize.zero ? Metrics.commentMediaTopPadding : Metrics.emptyCommentMediaTopPadding
                    )
                }
            })
            .disposed(by: disposeBag)

        viewModel.outputs.mediaSize
            .map { $0 == .zero }
            .bind(to: mediaView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.outputs.collapsableLabelViewModel
            .outputs.height
            .subscribe(onNext: { [weak self] newHeight in
                guard let self = self else { return }
                self.textHeightConstraint?.update(offset: newHeight)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.isEdited
            .map { !$0 }
            .bind(to: editedLabel.rx.isHidden)
            .disposed(by: disposeBag)

        if let editedLabelHeightConstraint = editedLabelHeightConstraint {
            viewModel.outputs.isEdited
                .map { !$0 }
                .bind(to: editedLabelHeightConstraint.rx.isActive)
                .disposed(by: disposeBag)
        }

        viewModel.outputs.isEdited
            .subscribe(onNext: { [weak self] isEdited in
                guard let self = self else { return }
                self.editedLabel.OWSnp.updateConstraints { make in
                    make.top.equalTo(self.mediaView.OWSnp.bottom).offset(isEdited ? Metrics.editedTopPadding : 0)
                }
            })
            .disposed(by: disposeBag)

        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.editedLabel.textColor = OWColorPalette.shared.color(type: .textColor2, themeStyle: currentStyle)
            }).disposed(by: disposeBag)
    }
}

fileprivate extension OWCommentContentView {
    func applyAccessibility() {
        // self.accessibilityIdentifier = Metrics.identifier
        textLabel.accessibilityIdentifier = Metrics.textLabelIdentifier
        mediaView.accessibilityIdentifier = Metrics.mediaViewIdentifier
        editedLabel.accessibilityIdentifier = Metrics.editedLabelIdentifier
    }
}

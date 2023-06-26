//
//  OWCommentCreationVC.swift
//  SpotImCore
//
//  Created by Alon Shprung on 05/09/2022.
//  Copyright © 2022 Spot.IM. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class OWCommentCreationVC: UIViewController {
    fileprivate struct Metrics {

    }

    fileprivate let viewModel: OWCommentCreationViewModeling
    fileprivate let disposeBag = DisposeBag()

    fileprivate lazy var commentCreationView: OWCommentCreationView = {
        let commentCreationView = OWCommentCreationView(viewModel: viewModel.outputs.commentCreationViewVM)
        return commentCreationView
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: OWCommentCreationViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        setupObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.inputs.viewDidLoad.onNext()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

fileprivate extension OWCommentCreationVC {
    func setupViews() {
        self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: .light)

        view.addSubview(commentCreationView)
        commentCreationView.OWSnp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }

    func setupObservers() {
        OWSharedServicesProvider.shared.themeStyleService()
            .style
            .subscribe(onNext: { [weak self] currentStyle in
                guard let self = self else { return }
                self.view.backgroundColor = OWColorPalette.shared.color(type: .backgroundColor2, themeStyle: currentStyle)
            })
            .disposed(by: disposeBag)

        // keyboard will show
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard
                    let self = self,
                    let expandedKeyboardHeight = notification.keyboardSize?.height,
                    let animationDuration = notification.keyboardAnimationDuration
                    else { return }
                let bottomPadding: CGFloat
                if #available(iOS 11.0, *) {
                    bottomPadding = self.tabBarController?.tabBar.frame.height ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.bottom ?? 0
                } else {
                    bottomPadding = 0
                }
                self.commentCreationView.OWSnp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-(expandedKeyboardHeight - bottomPadding))
                }
                UIView.animate(withDuration: animationDuration) { [weak self] in
                    guard let self = self else { return }
                    self.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)

        // keyboard will hide
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillHideNotification)
            .voidify()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.commentCreationView.OWSnp.updateConstraints { make in
                    make.bottom.equalTo(self.view.safeAreaLayoutGuide)
                }
            })
            .disposed(by: disposeBag)
    }
}

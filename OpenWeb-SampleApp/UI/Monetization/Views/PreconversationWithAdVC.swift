//
//  PreconversationWithAdVC.swift
//  OpenWeb-SampleApp
//
//  Created by Anael on 11/12/2024.
//

import RxSwift
import UIKit

class PreconversationWithAdVC: UIViewController {
    private struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        // 1.2 * screen height, defualt to 1200
        static let articleHeight: CGFloat = 1.2 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2 / 3
        static let articelImageViewCornerRadius: CGFloat = 10
        static let identifier = "mock_article_flows_vc_id"
        static let viewIdentifier = "mock_article_flows_view_id"
        static let loggerViewWidth: CGFloat = 300
        static let loggerViewHeight: CGFloat = 250
        static let loggerInitialTopPadding: CGFloat = 50
    }

    deinit {
        floatingLoggerView.removeFromSuperview()
    }

    private let viewModel: PreconversationWithAdViewModeling
    private let disposeBag = DisposeBag()

    private lazy var loggerView: UILoggerView = {
        return UILoggerView(viewModel: viewModel.outputs.loggerViewModel)
    }()

    private lazy var floatingLoggerView: OWFloatingView = {
        return OWFloatingView(viewModel: viewModel.outputs.floatingViewViewModel)
    }()

    private lazy var articleScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = ColorPalette.shared.color(type: .lightGrey)

        scroll.contentLayoutGuide.snp.makeConstraints { make in
            make.width.equalTo(scroll)
        }

        scroll.addSubview(articleView)
        articleView.snp.makeConstraints { make in
            make.edges.equalTo(scroll.contentLayoutGuide)
        }

        return scroll
    }()

    private lazy var articleView: UIView = {
        let article = UIView()

        article.snp.makeConstraints { make in
            make.height.equalTo(Metrics.articleHeight)
        }

        article.addSubview(imgViewArticle)
        imgViewArticle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Metrics.verticalMargin)
            make.centerX.equalToSuperview()
            make.width.equalTo(imgViewArticle.snp.height)
            make.width.equalToSuperview().multipliedBy(Metrics.articleImageRatio)
        }

        article.addSubview(lblArticleDescription)
        lblArticleDescription.snp.makeConstraints { make in
            make.top.equalTo(imgViewArticle.snp.bottom).offset(Metrics.verticalMargin)
            make.leading.trailing.equalToSuperview().inset(Metrics.horizontalMargin)
        }

        return article
    }()

    private lazy var imgViewArticle: UIImageView = {
        return UIImageView()
            .image(UIImage(named: "general_placeholder")!)
            .contentMode(.scaleAspectFit)
            .corner(radius: Metrics.articelImageViewCornerRadius)
    }()

    private lazy var lblArticleDescription: UILabel = {
        let txt = NSLocalizedString("MockArticleDescription", comment: "")

        return txt
            .label
            .numberOfLines(0)
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .text))
    }()

    init(viewModel: PreconversationWithAdViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override func loadView() {
        super.loadView()
        setupViews()
        applyAccessibility()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyLargeTitlesIfNeeded()
    }
}

private extension PreconversationWithAdVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        articleView.accessibilityIdentifier = Metrics.viewIdentifier
    }

    func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        articleScrollView.backgroundColor = ColorPalette.shared.color(type: .background)

        applyLargeTitlesIfNeeded()

        view.addSubview(articleScrollView)
        articleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        if #available(iOS 13.0, *) {
            #if !PUBLIC_DEMO_APP
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                // Add it to the window
                floatingLoggerView.isHidden = true
                keyWindow.addSubview(floatingLoggerView)
                floatingLoggerView.snp.makeConstraints { make in
                    make.width.equalTo(Metrics.loggerViewWidth)
                    make.height.equalTo(Metrics.loggerViewHeight)
                    make.top.equalToSuperview().offset(Metrics.loggerInitialTopPadding)
                    make.centerX.equalToSuperview()
                }
            }
            #endif
        }
    }

    // swiftlint:disable function_body_length
    func setupObservers() {
        title = viewModel.outputs.title

        viewModel.outputs.floatingViewViewModel.inputs.setContentView.onNext(loggerView)

        // Setting those in the VM for integration with the SDK
        viewModel.inputs.setNavigationController(self.navigationController)
        viewModel.inputs.setPresentationalVC(self)

        // Setup article image
        viewModel.outputs.articleImageURL
            .subscribe(onNext: { [weak self] url in
                self?.imgViewArticle.image(from: url)
            })
            .disposed(by: disposeBag)

        // Adding pre conversation
        viewModel.outputs.showPreConversation
            .subscribe(onNext: { [weak self] preConversationView in
                guard let self else { return }

                self.articleView.removeFromSuperview()
                self.articleScrollView.addSubview(self.articleView)
                self.articleScrollView.addSubview(preConversationView)

                // Constraints for preConversationView
                preConversationView.snp.makeConstraints { make in
                    make.top.greaterThanOrEqualTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.leading.trailing.equalTo(self.articleScrollView.contentLayoutGuide).inset(self.viewModel.outputs.preConversationHorizontalMargin)
                }

                // Constraints for articleView
                self.articleView.snp.makeConstraints { make in
                    make.top.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.leading.trailing.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(preConversationView.snp.top).offset(-Metrics.verticalMargin)
                }
            })
            .disposed(by: disposeBag)

        // Showing error if needed
        viewModel.outputs.showError
            .subscribe(onNext: { [weak self] message in
                self?.showError(message: message)
            })
            .disposed(by: disposeBag)

        viewModel.outputs.loggerEnabled
            .delay(.milliseconds(10), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] loggerEnabled in
                guard let self else { return }
                self.floatingLoggerView.isHidden = !loggerEnabled
            })
            .disposed(by: disposeBag)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
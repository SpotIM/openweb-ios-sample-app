//
//  MockArticleFlowsPartialScreenVC.swift
//  OpenWeb-SampleApp
//
//  Created by Alon Shprung on 22/10/2025.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit

class MockArticleFlowsPartialScreenVC: UIViewController {
    private struct Metrics {
        static let verticalMargin: CGFloat = 40
        static let horizontalMargin: CGFloat = 20
        // swiftlint:disable no_magic_numbers
        // 1.2 * screen height, default to 1200
        static let articleHeight: CGFloat = 1.2 * (UIApplication.shared.delegate?.window??.screen.bounds.height ?? 800)
        static let articleImageRatio: CGFloat = 2 / 3
        // swiftlint:enable no_magic_numbers
        static let articleImageViewCornerRadius: CGFloat = 10
        static let identifier = "mock_article_flows_partial_screen_vc_id"
        static let viewIdentifier = "mock_article_flows_partial_screen_view_id"
        static let loggerViewWidth: CGFloat = 300
        static let loggerViewHeight: CGFloat = 250
        static let loggerInitialTopPadding: CGFloat = 50
    }

    deinit {
        floatingLoggerView.removeFromSuperview()
    }

    private let viewModel: MockArticleFlowsPartialScreenViewModeling
    private var cancellables = Set<AnyCancellable>()

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
            .corner(radius: Metrics.articleImageViewCornerRadius)
    }()

    private lazy var lblArticleDescription: UILabel = {
        let txt = NSLocalizedString("MockArticleDescription", comment: "")

        return txt
            .label
            .numberOfLines(0)
            .font(FontBook.secondaryHeadingMedium)
            .textColor(ColorPalette.shared.color(type: .text))
    }()

    init(viewModel: MockArticleFlowsPartialScreenViewModeling) {
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        applyAccessibility()
        setupObservers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        applyLargeTitlesIfNeeded()
    }
}

private extension MockArticleFlowsPartialScreenVC {
    func applyAccessibility() {
        view.accessibilityIdentifier = Metrics.identifier
        articleView.accessibilityIdentifier = Metrics.viewIdentifier
    }

    @objc func setupViews() {
        view.backgroundColor = ColorPalette.shared.color(type: .background)
        articleScrollView.backgroundColor = ColorPalette.shared.color(type: .background)

        applyLargeTitlesIfNeeded()

        view.addSubview(articleScrollView)
        articleScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

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

    func setupObservers() {
        title = viewModel.outputs.title

        // Setting those in the VM for integration with the SDK
        viewModel.inputs.setPresentationalVC(self)

        viewModel.outputs.floatingViewViewModel.inputs.setContentView.send(loggerView)

        // Setup article image
        viewModel.outputs.articleImageURL
            .sink(receiveValue: { [weak self] url in
                self?.imgViewArticle.image(from: url)
            })
            .store(in: &cancellables)

        // Adding full conversation
        viewModel.outputs.showFullConversation
            .sink { [weak self] fullConversationVc in
                guard let self else { return }
                self.articleView.removeFromSuperview()
                self.articleScrollView.addSubview(self.articleView)
                self.articleScrollView.addSubview(fullConversationVc.view)

                self.addChild(fullConversationVc)

                fullConversationVc.view.snp.makeConstraints { make in
                    make.height.equalTo(500) // swiftlint:disable:this no_magic_numbers
                    make.bottom.equalTo(self.articleScrollView.snp.bottom).inset(300) // swiftlint:disable:this no_magic_numbers
                    make.leading.trailing.equalTo(self.articleScrollView.contentLayoutGuide)
                }
                fullConversationVc.didMove(toParent: self)

                self.articleView.snp.makeConstraints { make in
                    make.leading.trailing.top.equalTo(self.articleScrollView.contentLayoutGuide)
                    make.bottom.equalTo(fullConversationVc.view.snp.top).offset(-Metrics.verticalMargin)
                }
            }
            .store(in: &cancellables)

        // Showing error if needed
        viewModel.outputs.showError
            .sink(receiveValue: { [weak self] message in
                self?.showError(message: message)
            })
            .store(in: &cancellables)

        viewModel.outputs.loggerEnabled
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main) // swiftlint:disable:this no_magic_numbers
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loggerEnabled in
                guard let self else { return }
                self.floatingLoggerView.isHidden = !loggerEnabled
            })
            .store(in: &cancellables)
    }

    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

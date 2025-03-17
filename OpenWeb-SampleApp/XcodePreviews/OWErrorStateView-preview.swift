//
//  OWToastView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 10/03/2025.
//

@testable import OpenWebSDK
import SnapKit

extension OWErrorStateView {
    convenience init(type: OWErrorStateType) {
        let viewModel = OWErrorStateViewViewModel(errorStateType: type)
        self.init(with: viewModel)
        self.backgroundColor = .systemBackground
    }
}

@available(iOS 17.0, *)
#Preview {
    let scrollView = UIScrollView()
    let stackView = UIStackView(arrangedSubviews: [
            OWErrorStateView(type: .noNotifications),
            OWErrorStateView(type: .loadNotifications),
            OWErrorStateView(type: .loginNotifications),
            OWErrorStateView(type: .loadMoreConversationComments)
    ])
        .axis(.vertical)
        .spacing(32)
        .padding(16)
    scrollView.addSubview(stackView)
    scrollView.backgroundColor = .gray
    stackView.snp.makeConstraints { make in
        make.edges.equalToSuperview()
        make.centerX.equalToSuperview()
        make.width.equalTo(420)
    }
    return scrollView
}

//
//  OWConversationSummaryView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 15/01/2026.
//  Copyright © 2026 OpenWeb. All rights reserved.

#if DEBUG
@testable import OpenWebSDK
import UIKit
import Combine

class MockRealtimeServiceForSummary: StubRealtimeService {
    private let mockCommentsCount: Int
    private let mockOnlineUsersCount: Int
    
    init(commentsCount: Int = 42, onlineUsersCount: Int = 5) {
        mockCommentsCount = commentsCount
        mockOnlineUsersCount = onlineUsersCount
        super.init()
    }
    
    override var realtimeData: AnyPublisher<OWRealTime, Never> {
        let conversationId = OWConversationId.create(with: "preview_post_id")
        let jsonString = """
        {
            "data": {
                "conversation/count-messages": {
                    "\(conversationId)": [
                        {
                            "Comments": \(mockCommentsCount),
                            "Replies": 0
                        }
                    ]
                }
            },
            "nextFetch": 5000,
            "timestamp": 0
        }
        """
        
        let jsonData = Data(jsonString.utf8)
        do {
            let mockData = try OWDecoder.default.decode(OWRealTime.self, from: jsonData)
            return .just(mockData)
        } catch {
            print("Error decoding mock realtime data:", error)
            return .empty()
        }
    }
    
    override var onlineViewingUsersCount: AnyPublisher<Int, Never> {
        return Just(mockOnlineUsersCount).eraseToAnyPublisher()
    }
}

class MockSpotConfigServiceForSummary: StubSpotConfigurationService {
    var disableHeaderFacelist: Bool?
    
    init(disableHeaderFacelist: Bool? = false) {
        self.disableHeaderFacelist = disableHeaderFacelist
        super.init()
    }
    
    override func config(spotId: String) -> AnyPublisher<SPSpotConfiguration, Error> {
        let disableValue = disableHeaderFacelist.map { "\($0)" } ?? "null"
        let jsonString = """
        {
            "mobile-sdk": {
                "enabled": true,
                "openwebWebsiteUrl": "https://www.openweb.com",
                "openwebPrivacyUrl": "https://www.openweb.com/privacy",
                "openwebTermsUrl": "https://www.openweb.com/terms",
                "imageUploadBaseUrl": "https://images.spot.im",
                "fetchImageBaseUrl": "https://images.spot.im"
            },
            "conversation": {
                "disable_header_facelist": \(disableValue),
                "isAppealEnabled": false,
                "enableTabs": false,
                "showNotificationsBell": false,
                "statusFetchIntervalInMs": 300,
                "statusFetchTimeoutInMs": 3000,
                "statusFetchRetryCount": 12
            }
        }
        """
        
        let jsonData = Data(jsonString.utf8)
        do {
            let config = try OWDecoder.default.decode(SPSpotConfiguration.self, from: jsonData)
            return .just(config)
        } catch {
            print(error)
            return .error(error)
        }
    }
}

class PreviewWrapperView: UIView {
    private let segmentedControl: UISegmentedControl
    private var summaryView: OWConversationSummaryView?
    private let containerView = UIView()
    
    init() {
        segmentedControl = UISegmentedControl(items: ["Show (false)", "Hide (true)", "Default (nil)"])
        segmentedControl.selectedSegmentIndex = 0
        super.init(frame: .zero)
        setupUI()
        updateSummaryView(disableHeaderFacelist: false)
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        let controlsStackView = UIStackView(arrangedSubviews: [UILabel().text("Hide Face-List"), segmentedControl])
            .axis(.vertical)
            .spacing(16)
        addSubview(controlsStackView)
        addSubview(containerView)
        
        controlsStackView.OWSnp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        containerView.OWSnp.makeConstraints { make in
            make.top.equalTo(segmentedControl.OWSnp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    @objc private func segmentChanged() {
        let disableValue: Bool?
        switch segmentedControl.selectedSegmentIndex {
        case 0: disableValue = false
        case 1: disableValue = true
        case 2: disableValue = nil
        default: disableValue = false
        }
        updateSummaryView(disableHeaderFacelist: disableValue)
    }
    
    private func updateSummaryView(disableHeaderFacelist: Bool?) {
        summaryView?.removeFromSuperview()
        
        OWManager.manager.spotId = "preview_spot_id"
        
        let mockRealtimeService = MockRealtimeServiceForSummary()
        let mockConfigService = MockSpotConfigServiceForSummary(disableHeaderFacelist: disableHeaderFacelist)
        
        let mockServicesProvider = MockServicesProvider(
            realtimeService: mockRealtimeService,
            spotConfigurationService: mockConfigService
        )
        
        let viewModel = OWConversationSummaryViewModel(
            postId: "preview_post_id",
            servicesProvider: mockServicesProvider
        )
        
        let newSummaryView = OWConversationSummaryView(viewModel: viewModel)
        containerView.addSubview(newSummaryView)
        
        newSummaryView.OWSnp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        summaryView = newSummaryView
    }
}

@available(iOS 17, *)
#Preview {
    let wrapper = PreviewWrapperView()
    wrapper.OWSnp.makeConstraints { make in
        make.width.equalTo(380)
    }
    return wrapper
}
#endif

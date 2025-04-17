//
//  OWNotificationBellView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 07/04/2025.
//

#if DEBUG
@testable import OpenWebSDK
import RxSwift

@available(iOS 17.0, *)
#Preview {
    UIStackView(arrangedSubviews: [
        bellWithCount(0),
        bellWithCount(1),
        bellWithCount(7),
        bellWithCount(42),
        bellWithCount(100),
        bellWithCount(10000),
    ])
    .axis(.vertical)
    .spacing(32)
    .padding(16)
}

private func bellWithCount(_ count: Int) -> UIView {
    return UIStackView(arrangedSubviews: [
        OWNotificationBellView(unseenCount: count),
        UILabel().text(count.description),
    ])
    .spacing(8)
}

private extension OWNotificationBellView {
    convenience init(unseenCount: Int) {
        let vm = OWNotificationsBellViewModel(
            servicesProvider: MockServicesProvider(
                networkAPI: MockNetworkAPI(unseenCount: unseenCount),
                realtimeService: MockUnseenCountRealtimeService(unseenCount: unseenCount)
            ),
            postId: "mockPostId",
            viewableMode: .independent
        )
        self.init(viewModel: vm)
    }
}

private class MockNetworkAPI: StubNetworkAPI {
    private let mockNotificationsAPI: MockNotificationsAPI

    init(unseenCount: Int) {
        self.mockNotificationsAPI = MockNotificationsAPI(unseenCount: unseenCount)
        super.init()
    }

    override var notifications: OWNotificationsAPI { return mockNotificationsAPI }
}

private class MockNotificationsAPI: OWNotificationsAPI {
    private let progress = PublishSubject<Progress>()
    private let unseenCount: Int

    init(unseenCount: Int) {
        self.unseenCount = unseenCount
        let progressValue = Progress(totalUnitCount: 1)
        progressValue.completedUnitCount = 1
        progress.onNext(progressValue)
    }

    func getNotifications(offset: Int?, count: Int, postId: OWPostId) -> OWNetworkResponse<OWNotificationsResponse> {
        let response = OWNotificationsResponse(notifications: [], totalUnread: unseenCount, totalUnseen: unseenCount, total: unseenCount, cursor: nil)
        return OWNetworkResponse(progress: progress, response: Observable.just(response))
    }

    func resetUnseen(postId: OWPostId) -> OWNetworkResponse<OWNetworkEmpty> {
        return OWNetworkResponse(progress: progress, response: Observable.just(OWNetworkEmpty()))
    }

    func markAsRead(notificationIds: [String], postId: OWPostId) -> OWNetworkResponse<OWNetworkEmpty> {
        return OWNetworkResponse(progress: progress, response: Observable.just(OWNetworkEmpty()))
    }
}

private class MockUnseenCountRealtimeService: OWRealtimeServicing {
    func startFetchingData(postId: OpenWebCommon.OWPostId) {}
    func stopFetchingData() {}
    func reset() {}

    private let _realtimeData = BehaviorSubject<OWRealTime?>(value: nil)
    lazy var realtimeData: Observable<OWRealTime> = {
        _realtimeData
            .unwrap()
    }()

    let onlineViewingUsersCount = Observable.just(0)
    let currentPostIsReadOnly = Observable.just(false)
    let currentPostId = Observable.just("mockPostId")

    init(unseenCount: Int) {
        OWManager.manager.spotId = "sp_JO8jQVTJ_aio1"
        self.unseenCount = unseenCount
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let data = try decoder.decode(OWRealTime.self, from: json.data(using: .utf8)!)
            _realtimeData.onNext(data)
        } catch {
            print("**** JSONDecoder error", error)
        }
    }

    private let unseenCount: Int
    private lazy var json = """
        {
        "data": {
            "conversation/notifications-count": {
                "sp_JO8jQVTJ_aio1": [
                    {
                        "unseen": \(unseenCount)
                    }
                ]
            },
            "conversation/realtime-notifications": {
                "sp_JO8jQVTJ_no$post": [
                    {
                        "notifications": [
                            {
                                "conversation_id": "sp_JO8jQVTJ_aio1",
                                "conversation_title": "aio1",
                                "conversation_url": "http://www.spotim.name/integration/aio_env/aio1.html",
                                "id": "0:liked_your_message:1:c:sp_JO8jQVTJ_aio1_c_2pytQe9LZWJndseUQmCXT7r6xlR:sp_JO8jQVTJ_aio1",
                                "liker_id": "u_bnkwdSC3cIKZ",
                                "liker_ids": [
                                    "u_bnkwdSC3cIKZ"
                                ],
                                "message": {
                                    "content": [
                                        {
                                            "id": "be223f03c557f4400611258eb8d20620",
                                            "text": "some text",
                                            "type": "text"
                                        }
                                    ],
                                    "id": "sp_JO8jQVTJ_aio1_c_2pytQe9LZWJndseUQmCXT7r6xlR",
                                    "metadata": {
                                        "previous_state": "approved"
                                    },
                                    "timestamp": 1733750127,
                                    "type": "comment"
                                },
                                "read": false,
                                "total_count": 1,
                                "type": "liked-message",
                                "updated_at": 1735043121,
                                "users": [
                                    {
                                        "id": "u_bnkwdSC3cIKZ",
                                        "user_name": "Guest",
                                        "display_name": "RedFlame",
                                        "image_id": "#Red-Flame",
                                        "registered": false
                                    }
                                ]
                            }
                        ]
                    }
                ]
            }
        },
        "next_fetch": 1735043125,
        "timestamp": 1735043120
    }
    """
}

#endif

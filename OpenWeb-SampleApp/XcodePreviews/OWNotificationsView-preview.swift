//
//  OWNotificationsView-preview.swift
//  OpenWeb-SampleApp
//
//  Created by Yonat Sharon on 10/04/2025.
//

#if DEBUG
@testable import OpenWebSDK
import RxSwift

@available(iOS 17.0, *)
#Preview {
    OpenWeb.manager.spotId = "sp_JO8jQVTJ"

    let notificationsData = OWNotificationsRequiredData(
        presentationalMode: .push,
        article: OWArticle.stub(),
        postId: "sp_JO8jQVTJ_aio1"
    )

    let viewModel = OWNotificationsViewViewModel(
        data: notificationsData,
        servicesProvider: MockServicesProvider(networkAPI: MockNotificationsNetworkAPI())
    )
    viewModel.inputs.viewInitialized.onNext(())

    return OWNotificationsView(viewModel: viewModel)
}

// swiftlint:disable function_body_length line_length
class MockNotificationsNetworkAPI: OWNetworkAPIProtocol {
    // Return fatalError for API properties as they are not stubbed
    var networkErrors = PublishSubject<OWNetworkError>()
    var analytics: OWAnalyticsAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var realtime: OWRealtimeAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var configuration: OWConfigurationAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var profile: OWProfileAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var user: OWUserAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var images: OWImagesAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var authentication: OWAuthenticationAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var conversation: OWConversationAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var reportReason: OWReportReasonAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var failureReporter: OWFailureReportAPI { fatalError("API not stubbed in MockingServicesProvider") }
    var appeal: OWAppealAPI { fatalError("API not stubbed in MockingServicesProvider") }

    lazy var notifications: OWNotificationsAPI = MockListNotificationsAPI()

    func request(for endpoint: OWEndpoints) -> OWURLRequestConfiguration {
        return StubURLRequestConfiguration()
    }
}

class MockListNotificationsAPI: OWNotificationsAPI {
    private let progress = PublishSubject<Progress>()

    func getNotifications(offset: Int?, count: Int, postId: OWPostId) -> OWNetworkResponse<OWNotificationsResponse> {
        // Complete the progress immediately to avoid showing loading state
        let progressValue = Progress(totalUnitCount: 1)
        progressValue.completedUnitCount = 1
        progress.onNext(progressValue)

        let jsonData = Data("""
        {
            "notifications": [
                {
                    "conversation_id": "sp_JO8jQVTJ_aio1",
                    "conversation_title": "aio1",
                    "conversation_url": "http://www.spotim.name/integration/aio_env/aio1.html",
                    "id": "0:replied_to_message:1:c:sp_JO8jQVTJ_aio1_c_2qf07CrW1XS3tme5HoCtWumlnbr:r:sp_JO8jQVTJ_aio1_c_2qf07CrW1XS3tme5HoCtWumlnbr_r_2qf0LJYi1I0QIuKn9NWRwyD50UK:sp_JO8jQVTJ_aio1",
                    "message": {
                        "content": [
                            {
                                "id": "1c7a174409f5d561a21f5119e8e81602",
                                "text": "some comment text",
                                "type": "text"
                            }
                        ]
                    },
                    "read": false,
                    "replier_id": "u_zvQz4kXXHeIn",
                    "reply": {
                        "content": [
                            {
                                "id": "7670ac9eabec46c09dcbb083d66ccb20",
                                "text": "some reply text",
                                "type": "text"
                            }
                        ],
                        "id": "sp_JO8jQVTJ_aio1_c_2qf07CrW1XS3tme5HoCtWumlnbr_r_2qf0LJYi1I0QIuKn9NWRwyD50UK",
                        "metadata": {
                            "previous_state": "approved"
                        },
                        "timestamp": 1735038264,
                        "type": "reply"
                    },
                    "total_count": 1,
                    "type": "replied-your-message",
                    "updated_at": 1735038712,
                    "users": [
                        {
                            "id": "u_zvQz4kXXHeIn",
                            "user_name": "bro211",
                            "display_name": "Bro",
                            "image_id": "#Gold-Toast",
                            "registered": true
                        }
                    ]
                },
                {
                    "conversation_id": "sp_JO8jQVTJ_aio1",
                    "conversation_title": "aio1",
                    "conversation_url": "http://www.spotim.name/integration/aio_env/aio1.html",
                    "id": "0:user_mentioned:1:u_zvQz4kXXHeIn:c:sp_JO8jQVTJ_aio1_c_2qf0NCMXIIWAAseYzDMfnxPPzii:sp_JO8jQVTJ_aio1",
                    "mentioner_id": "u_zvQz4kXXHeIn",
                    "message": {
                        "content": [
                            {
                                "id": "074519e95230a4982555cc6bfb30c251",
                                "text": "Hi data-mention=\\"u_8epfK5EY1yxc,Oleksandr Tyshkovets,OleksandrTyshkovets\\" data-mention-id=\\"f8d530c918e56c4d3d180cac95fa0c63\\"@Oleksandr Tyshkovets how are you?",
                                "type": "text"
                            },
                            {
                                "id": "f8d530c918e56c4d3d180cac95fa0c63",
                                "type": "user-mention",
                                "userId": "u_8epfK5EY1yxc"
                            }
                        ],
                        "id": "sp_JO8jQVTJ_aio1_c_2qf0NCMXIIWAAseYzDMfnxPPzii",
                        "metadata": {
                            "previous_state": "approved"
                        },
                        "timestamp": 1735038279,
                        "type": "comment"
                    },
                    "read": false,
                    "total_count": 1,
                    "type": "user-mentioned",
                    "updated_at": 1735038670,
                    "users": [
                        {
                            "id": "u_8epfK5EY1yxc",
                            "user_name": "OleksandrTyshkovets",
                            "display_name": "Oleksandr Tyshkovets",
                            "image_id": "p/u/bdzlp9wkoza8cilb2d6z",
                            "registered": true
                        },
                        {
                            "id": "u_zvQz4kXXHeIn",
                            "user_name": "bro211",
                            "display_name": "Bro",
                            "image_id": "#Gold-Toast",
                            "registered": true
                        }
                    ]
                },
                {
                    "article_url": "https://www.ign.com/articles/marvel-rivals-director-and-entire-seattle-design-team-laid-off-netease-tells-fans-not-to-worry-about-the-game",
                    "description": "Marvel Rivals developer NetEase has confirmed cuts to its Seattle-based design team for 'organizational reasons'",
                    "id": "c860fae6-33bb-45dd-b633-dd49ab52c726",
                    "image_id": "production/nrnwsggzrbjufq0pxmhq",
                    "read": true,
                    "seen": false,
                    "title": "Marvel Rivals Director and Entire Seattle Design Team Laid Off, NetEase Tells Fans Not to Worry About the Game - IGN",
                    "topic_name": "PlayStation 5",
                    "topic_type": "keyword",
                    "type": "topic-notification",
                    "updated_at": 1739959540
                },
                {
                    "conversation_id": "sp_JO8jQVTJ_aio1",
                    "conversation_title": "aio1",
                    "conversation_url": "http://www.spotim.name/integration/aio_env/aio1.html",
                    "id": "0:liked_your_message:1:c:sp_JO8jQVTJ_aio1_c_2qf07CrW1XS3tme5HoCtWumlnbr:sp_JO8jQVTJ_aio1",
                    "liker_id": "u_zvQz4kXXHeIn",
                    "liker_ids": [
                        "u_zvQz4kXXHeIn"
                    ],
                    "message": {
                        "content": [
                            {
                                "id": "1c7a174409f5d561a21f5119e8e81602",
                                "text": "comment",
                                "type": "text"
                            }
                        ],
                        "id": "sp_JO8jQVTJ_aio1_c_2qf07CrW1XS3tme5HoCtWumlnbr",
                        "metadata": null,
                        "timestamp": 1735038152,
                        "type": "comment"
                    },
                    "read": false,
                    "total_count": 1,
                    "type": "liked-message",
                    "updated_at": 1735038163,
                    "users": [
                        {
                            "id": "u_zvQz4kXXHeIn",
                            "user_name": "bro211",
                            "display_name": "Bro",
                            "image_id": "#Gold-Toast",
                            "registered": true
                        }
                    ]
                }
            ],
            "total_unread": 3,
            "total_unseen": 0,
            "total": 4,
            "cursor": {
                "offset_v1": 4,
                "offset_v2": 0
            }
        }
        """.utf8)

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response = try decoder.decode(OWNotificationsResponse.self, from: jsonData)
            return OWNetworkResponse(progress: progress, response: .just(response))
        } catch {
            print("Error decoding JSON:", error)
            return OWNetworkResponse(progress: progress, response: .error(error))
        }
    }

    func resetUnseen(postId: OWPostId) -> OWNetworkResponse<OWNetworkEmpty> {
        let progressValue = Progress(totalUnitCount: 1)
        progressValue.completedUnitCount = 1
        progress.onNext(progressValue)
        return OWNetworkResponse(progress: progress, response: .just(OWNetworkEmpty()))
    }

    func markAsRead(notificationIds: [String], postId: OWPostId) -> OWNetworkResponse<OWNetworkEmpty> {
        return OWNetworkResponse(progress: progress, response: .just(OWNetworkEmpty()))
    }

}
#endif

//
//  RealTimeService.swift
//  SpotImCore
//
//  Created by Eugene on 13.11.2019.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import Foundation

protocol RealTimeServiceDelegate: class {
    
    func realTimeDataDidUpdate(realTimeData: RealTimeModel, shouldUserBeNotified: Bool, timeOffset: Int)
}

final class RealTimeService {
    
    weak var delegate: RealTimeServiceDelegate?
    
    private let dataProvider: SPRealtimeDataProvider
    private var nextFetchTimeOffset: Int = 0
    private weak var realTimeTimer: Timer?
    private var stoppedConversations: Set<String> = Set<String>()
    private var nextRequestTimeOffset: Int = 5
    private var failuresInARow: Int = 0
    private var currentConversationId: String?

    /// Creates an instance only if the feature enabled on the server
    init?(realTimeDataProvider: SPRealtimeDataProvider) {
        guard SPConfigsDataSource.appConfig?.mobileSdk?.realtimeEnabled == true else { return nil }
        dataProvider = realTimeDataProvider
    }
    
    /// Start realtime data polling for `conversationId`
    func startRealTimeDataFetching(conversationId: String) {
        currentConversationId = conversationId
        failuresInARow = 0
        fetchDataForConversation(id: conversationId)
    }
    
    /// Stop realtime data polling for `conversationId`
    func stopRealTimeDataFetching(conversationId: String) {
        stoppedConversations.insert(conversationId)
    }
    
    /// Take off  service fetch if it was stopped
    func refreshService() {
        failuresInARow = 0
        
        guard
            let convId = currentConversationId,
            !dataProvider.isFetching,
            !(realTimeTimer?.isValid ?? false)
            else { return }
        
        startRealTimeDataFetching(conversationId: convId)
    }
    
    private func scheduleNextRealTimeFetch(offset: Int, conversationId: String) {
        guard offset > 0
            else {
                realTimeTimer?.invalidate()
                return
        }
        
        realTimeTimer = Timer.scheduledTimer(
            withTimeInterval: Double(offset),
            repeats: false
        ) { [weak self] _ in
            self?.fetchDataForConversation(id: conversationId)
        }
    }
    
    private func fetchDataForConversation(id: String) {
        dataProvider.fetchRealtimeData(conversationId: id) { [weak self] result, _ in
            guard
                let self = self
                else { return }
            
            if let result = result {
                self.failuresInARow = 0
                self.nextRequestTimeOffset = result.nextFetch - result.timestamp
                self.scheduleNextRealTimeFetch(offset: result.nextFetch - result.timestamp, conversationId: id)
                let shouldUserBeNotified = !self.stoppedConversations.contains(id)
                    && self.stoppedConversations.count < 3
                
                self.delegate?.realTimeDataDidUpdate(
                    realTimeData: result,
                    shouldUserBeNotified: shouldUserBeNotified,
                    timeOffset: self.nextRequestTimeOffset
                )
            } else if self.failuresInARow <= 3 {
                self.failuresInARow += 1
                self.scheduleNextRealTimeFetch(offset: self.nextRequestTimeOffset, conversationId: id)
            }
        }
    }
}

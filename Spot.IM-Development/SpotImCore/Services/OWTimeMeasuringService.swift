//
//  OWTimeMeasuringService.swift
//  SpotImCore
//
//  Created by Revital Pisman on 11/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWTimeMeasuringServicing {
    func startMeasure(forKey key: OWTimeMeasuringService.OWKeys)
    func endMeasure(forKey key: OWTimeMeasuringService.OWKeys) -> OWTimeMeasuringResult
}

enum OWTimeMeasuringResult {
    case time(milliseconds: Int)
    case error(message: String)
}

class OWTimeMeasuringService: OWTimeMeasuringServicing {
    
    enum OWKeys: String {
        case conversationUIBuildingTime
    }
    
    fileprivate var startTimeDictionary = [String: CFAbsoluteTime]()
    
    func startMeasure(forKey key: OWTimeMeasuringService.OWKeys) {
        startTimeDictionary[key.rawValue] = CFAbsoluteTimeGetCurrent()
    }
    
    func endMeasure(forKey key: OWTimeMeasuringService.OWKeys) -> OWTimeMeasuringResult {
        guard let startTime = startTimeDictionary[key.rawValue] else {
            return .error(message: "Error: start measure must be called before end measure")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let timeElapsed = (endTime - startTime) * 1000
        
        startTimeDictionary.removeValue(forKey: key.rawValue)
        
        return .time(milliseconds: Int(timeElapsed))
    }
}

fileprivate extension OWTimeMeasuringService.OWKeys {
    
    var description: String {
        switch self {
        case .conversationUIBuildingTime:
            return "Time for building initial UI in conversation view"
        }
    }
}

//
//  OWTimeMeasuringService.swift
//  SpotImCore
//
//  Created by Revital Pisman on 11/01/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

protocol OWTimeMeasuringServicing {
    func startMeasure(forKey key: String)
    func endMeasure(forKey key: String) -> OWTimeMeasuringResult
}

enum OWTimeMeasuringResult {
    case success(time: Int)
    case error(message: String)
}

class OWTimeMeasuringService: OWTimeMeasuringServicing {
    
    fileprivate var startTimeDictionary = [String: CFAbsoluteTime]()
    
    func startMeasure(forKey key: String) {
        startTimeDictionary[key] = CFAbsoluteTimeGetCurrent()
    }
    
    func endMeasure(forKey key: String) -> OWTimeMeasuringResult {
        guard let startTime = startTimeDictionary[key] else {
            return .error(message: "Error: start measure must be called before end measure")
        }
        
        let endTime = CFAbsoluteTimeGetCurrent()
        let timeElapsed = (endTime - startTime) * 1000
        
        startTimeDictionary.removeValue(forKey: key)
        
        return .success(time: Int(timeElapsed))
    }
}

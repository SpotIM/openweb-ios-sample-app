//
//  OWPageViewIdHolder.swift
//  SpotImCore
//
//  Created by Alon Haiut on 20/08/2023.
//  Copyright © 2023 Spot.IM. All rights reserved.
//

import Foundation

/* Since there is no point to save the pageViewId in user defaults or other persistence,
 I chose to create an holder / simple service for that which will be in the shared service provider.
*/

protocol OWPageViewIdHolderProtocol {
    func generateNewPageViewId()
    // Initially the returned page view id will be an empty string
    var pageViewId: String { get }
}

class OWPageViewIdHolder: OWPageViewIdHolderProtocol {

    fileprivate var _pageViewId: String = ""
    fileprivate let randomGenerator: OWRandomGeneratorProtocol

    init(randomGenerator: OWRandomGeneratorProtocol = OWRandomGenerator()) {
        self.randomGenerator = randomGenerator
    }

    func generateNewPageViewId() {
        _pageViewId = randomGenerator.generateSuperiorUUID()
    }

    var pageViewId: String {
        return _pageViewId
    }

}

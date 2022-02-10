//
//  Spot_IM_DevelopmentTests.swift
//  Spot-IM.DevelopmentTests
//
//  Created by Andriy Fedin on 16/06/19.
//  Copyright © 2019 Spot.IM. All rights reserved.
//

import XCTest
@testable import SpotImCore

class Spot_IM_ConfigApiTests: XCTestCase {
    
    var configJson:Dictionary<String, AnyObject>? = nil;
    var configJsonGoogleTrue:Dictionary<String, AnyObject>? = nil;
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.configJson = SPTestsUtils().readJsonFromFile(fileName: "sp_config_response")
        self.configJsonGoogleTrue = SPTestsUtils().readJsonFromFile(fileName: "sp_config_response_google_true")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testJsonWasReadAsExpected() {
        XCTAssertNotNil(self.configJson)
        XCTAssertNotNil(self.configJson?["time-spent"])
        XCTAssertEqual(self.configJson?["time-spent"]?["intersection_values"] as! Int, 20)
        XCTAssertTrue(self.configJson?["time-spent"]?["intersection_values"] as! Int != 21)
    }
    
    func testSPSpotConfigurationParsing() {
        let spotConfig = OWDecodableParser<SPSpotConfiguration>().parse(object: self.configJson).value
        XCTAssertNotNil(spotConfig)
        XCTAssertTrue(spotConfig?.mobileSdk.enabled as! Bool)
        XCTAssertEqual(spotConfig?.mobileSdk.openwebPrivacyUrl, "https://www.openweb.com/legal-and-privacy/privacy?utm_source=Product\u{0026}utm_medium=Footer", "")
    }
    
    func testGoogleAdsProviderKey() {
        let spotConfig = OWDecodableParser<SPSpotConfiguration>().parse(object: self.configJson).value
        let spotConfigGoogleTrue = OWDecodableParser<SPSpotConfiguration>().parse(object: self.configJsonGoogleTrue).value
        
        XCTAssertNotNil(spotConfig)
        XCTAssertNotNil(spotConfigGoogleTrue)
        
        XCTAssertFalse(spotConfig?.mobileSdk.googleAdsProviderRequired as! Bool)
        XCTAssertTrue(spotConfigGoogleTrue?.mobileSdk.googleAdsProviderRequired as! Bool)
    }
}

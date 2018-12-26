//
//  RosterViewTests.swift
//  Simply CountedTests
//
//  Created by Nicholas Karavakis on 9/28/18.
//  Copyright © 2018 Jennifer Karavakis. All rights reserved.
//

import XCTest

@testable import simply_counted

class AppStoreReviewPromptTests: XCTestCase {

    
    var appStoreReviewPrompt: AppStoreReviewPrompt!;
    var rosterTableView: UITableView!;
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
        appStoreReviewPrompt = AppStoreReviewPrompt()
        rosterTableView = UITableView()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUserDefaultsAppStorePromptCounterChanged() {
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        mockUserDefaults.setAppStorePromptCounter(value: 10)
        mockUserDefaults.setPreviousBundleVersion(value: "1.6.2")
        appStoreReviewPrompt.userDefaults = mockUserDefaults
        appStoreReviewPrompt.displayPrompt()
        
        XCTAssertTrue(mockUserDefaults.appStorePromptCounterWasChanged, "The app store prompt counter should have been changed")
        XCTAssert(mockUserDefaults.appStorePromptCounter == 11)
    }
    
    func testUserDefaultsAppStorePromptCounterReset() {
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        mockUserDefaults.setAppStorePromptCounter(value: 20)
        mockUserDefaults.setPreviousBundleVersion(value: "1.6.2")
        appStoreReviewPrompt.userDefaults = mockUserDefaults
        appStoreReviewPrompt.displayPrompt()
        
        XCTAssertTrue(mockUserDefaults.appStorePromptCounterWasChanged, "The app store prompt counter should have been changed")
        XCTAssert(mockUserDefaults.appStorePromptCounter == 0)
    }
    
    func testPreviousBundleVersionChanged() {
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        mockUserDefaults.setPreviousBundleVersion(value: "1.0.0")
        mockUserDefaults.set("1.0.0", forKey: "previous_bundle_version")
        appStoreReviewPrompt.userDefaults = mockUserDefaults
        appStoreReviewPrompt.displayPrompt()

        XCTAssertTrue(mockUserDefaults.appStorePromptCounterWasChanged, "The app store prompt counter should have been changed")
        XCTAssert(mockUserDefaults.previousBundleVersion == "1.6.2")
        XCTAssert(mockUserDefaults.appStorePromptCounter == 0)
    }
}


class MockUserDefaults : UserDefaults {
    var appStorePromptCounterWasChanged = false
    var previousBundleVersionWasChanged = false
    var appStorePromptCounter = 0
    var previousBundleVersion = "0.0"
    
    convenience init() {
        self.init(suiteName: "Mock User Defaults")!
    }
    
    override init?(suiteName: String?) {
        UserDefaults().removePersistentDomain(forName: suiteName!)
        super.init(suiteName: suiteName)
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        if defaultName == "app_store_prompt_counter" {
            appStorePromptCounterWasChanged = true
            setAppStorePromptCounter(value: value as! Int)
        } else if defaultName == "previous_bundle_version" {
            previousBundleVersionWasChanged = true
            setPreviousBundleVersion(value: value as! String)
        }
    }
    
    func setAppStorePromptCounter(value: Int) {
        self.appStorePromptCounter = value
    }

    func setPreviousBundleVersion(value: String) {
        self.previousBundleVersion = value
    }
    
    override func integer(forKey defaultName: String) -> Int {
        if defaultName == "app_store_prompt_counter" {
            return appStorePromptCounter
        }
        
        return 0
    }
    
    override func string(forKey defaultName: String) -> String? {
        if defaultName == "previous_bundle_version" {
            return previousBundleVersion
        }
        
        return "0"
    }
}

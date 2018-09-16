//
//  ClientTests.swift
//  simply_counted
//
//  Created by Nicholas Karavakis on 9/14/17.
//  Copyright © 2017 Jennifer Karavakis. All rights reserved.
//

import XCTest

@testable import simply_counted

class ClientTests: XCTestCase {
    
    var client: Client!;
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        client = Client(name: "Test Client");
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testClientCheckin() {
        let date = Date();
        client.passes = 10
        client.checkIn(date)
        let checkinDate: Date = client.lastCheckIn!
        
        XCTAssert(date == checkinDate)
        XCTAssert(client.totalCheckIns == 1)
        
        XCTAssert(client.passes == 9)
        XCTAssert(client.activities.count == 1)
    }
    
    func testClientAddNewPass() {
        let pass = PassType(passCount: 1, price: "1.50")
        
        client.addPasses(pass)
        
        XCTAssert(client.passes == 1)
        XCTAssert(client.totalPasses == 1)
        
        client.updatePassesLeft(0, successHandler: nil)
        XCTAssert(client.passes == 0)
        XCTAssert(client.totalPasses == 1)
    }
    
    
}

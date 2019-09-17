//
//  EventModelTest.swift
//  eventsTests
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import XCTest
@testable import events

/**
 * Test cases for EventModel
 */
class EventModelTest: XCTestCase {

    /**
     * Test codable for AnyEvent.
     */
    func testAnyEventCodable() {

        let testJson = #"""
{"title":"Test",
 "start":"September 02, 2019 12:04 AM",
"end":"September 02, 2019 12:05 AM"}
"""#
        do {
            let data1 = testJson.data(using: .utf8)!
            let event1: DefaultEvent = try DefaultEvent.decodeEvent(data1)

            let jsonData = try event1.encodeEvent()
            let event2: DefaultEvent = try DefaultEvent.decodeEvent(jsonData)
            XCTAssertEqual(event1, event2)
            XCTAssertEqual(event2.start.shortEventStr, "September 02, 2019")
        } catch {
            XCTFail("Failed to encode or decode json: \(error.localizedDescription)")
        }
    }
}

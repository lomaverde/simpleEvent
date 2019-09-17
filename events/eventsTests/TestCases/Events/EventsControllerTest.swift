//
//  EventsControllerTest.swift
//  eventsTests
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import XCTest
@testable import events

/**
 * Test cases for EventsController.
 */
class EventsControllerTest: XCTestCase {

    /**
     * Test loading and updating the view models in UpcomingEventsController
     */
    func testLoad() {
        var eventController = NestedLoopEventsManager()
        do {
            try eventController.load()
            XCTAssertTrue(eventController.events.count > 0)
            let viewModel = eventController.eventsViewModel
            XCTAssertTrue(viewModel.eventStartDates.count > 0)
            XCTAssertTrue(viewModel.eventsByDate.count == viewModel.eventStartDates.count)
            if let firstDate = viewModel.eventStartDates.first,
                let firstDateFromEvents = viewModel.eventsByDate[firstDate]?.first{
               XCTAssertEqual(firstDate.shortEventStr, firstDateFromEvents.start.shortEventStr)
            }
        } catch {
            XCTFail("Failed to encode json: \(error.localizedDescription)")
        }
    }
}


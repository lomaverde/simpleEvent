//
//  EventsViewModelTest.swift
//  eventsTests
//
//  Created by Mei Yu on 9/11/19.
//  Copyright © 2019 mei. All rights reserved.
//

import XCTest
@testable import events

class EventsViewModelTest: XCTestCase {
    
    let date1 = Date().addingTimeInterval(-100)
    let date2 = Date().addingTimeInterval(-50)
    let date3 = Date()
    let date4 = Date().addingTimeInterval(50)
    let date5 = Date().addingTimeInterval(100)
    
    func testProcessEventsHasConflicts() {
        let events: [DefaultEvent] = [
            DefaultEvent(title: "test1", start: date1, end: date2),
            DefaultEvent(title: "test2", start: date1, end: date2),
            DefaultEvent(title: "test3", start: date2, end: date3)
            ]
        
        var viewModel = NestedLoopsViewModel()
        let eventWithConflict = events.first!
        let eventNoConflict = events.last!
        _ = viewModel.processEvents(events)
        XCTAssertTrue(viewModel.hasConflict(eventWithConflict))
        XCTAssertFalse(viewModel.hasConflict(eventNoConflict))
    }
    
    func testTreeEventModel() {
        let events: [DefaultEvent] = [
            DefaultEvent(title: "test1", start: date1, end: date2),
            DefaultEvent(title: "test2", start: date1, end: date2),
            DefaultEvent(title: "test3", start: date2, end: date3)
        ]
        
        let viewModel = TreeEventsViewModel()
        let eventWithConflict = events.first!
        let eventNoConflict = events.last!
        _ = viewModel.processEvents(events)
        XCTAssertTrue(viewModel.hasConflict(eventWithConflict))
        XCTAssertFalse(viewModel.hasConflict(eventNoConflict))
    }
}

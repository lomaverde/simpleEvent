//
//  EventsManager.swift
//  MeiEvents
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

/**
 * This is the manager for Events which fetch the data from backend and update the view models.
 */
protocol EventsManager {

    associatedtype EventsViewModelT: EventsViewModel
    typealias EventType = EventsViewModelT.EventType

    /// View Model for the events
    var eventsViewModel: EventsViewModelT { get set }

    /// Array of events from backend
    var events: [EventType] { get set }

    /// json file name for the source JSON
    var jsonFileName: String { get }
}

extension EventsManager {

    var jsonFileName: String { return "upcomingEvents" }

    /// Loads the data from backend and updates the view model.
    ///
    /// - throws: errors from Codable.decodeEvent and Data(contentsOf:)
    mutating func load() throws {
        guard let path = Bundle.main.url(forResource: jsonFileName, withExtension: "json")
            else {
                Log.error(nil, "Error with finding json file")
                return
        }

        do {
            let jsonData = try Data(contentsOf: path)
            events = try [EventType].decodeEvent(jsonData)
            eventsViewModel.update(with: events)
        } catch {
            Log.error(error, "Failed to decode json")
            throw error
        }
    }
}

/// Manager for using the view model with Nested Loops
struct NestedLoopEventsManager: EventsManager {
    typealias EventsViewModelT = NestedLoopsViewModel
    var eventsViewModel = NestedLoopsViewModel()
    var events = [EventType]()
}


// Manager Using Interval Tree View Model.
struct TreeEventsManager: EventsManager {
    typealias EventsViewModelT = TreeEventsViewModel
    var eventsViewModel = TreeEventsViewModel()
    var events = [EventType]()
}

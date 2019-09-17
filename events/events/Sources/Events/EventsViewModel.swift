//
//  EventsViewModel.swift
//  events
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

/**
 * View Model for a collection of Events
 */
protocol EventsViewModel {

    associatedtype EventType: EventModel

    // Sorted array of start dates for events
    var eventStartDates: [Date] { get set }

    // Dictionary of sorted array of events with start data as key
    var eventsByDate: [Date: [EventType]] { get set }
    
    mutating func processEvents(_ events: [Self.EventType]) -> [Self.EventType]
    
    var conflicts: [EventType: Set<EventType>] { get set }
    
    /// has conflict with other events
    func hasConflict(_ event: EventType) -> Bool
    
    func conflictForEvent(_ event: EventType) -> Set<EventType>?
}

extension EventsViewModel {

    /// Returns number of days for the events
    var numOfDays: Int { return eventStartDates.count }

    /// Returns Date for the giving index
    func date(for dateIndex: Int) -> Date? {
        guard dateIndex < eventStartDates.count
            else { return nil }
        return eventStartDates[dateIndex]
    }

    /// Return number of events for the giving index
    func numOfEvents(for dateIndex: Int) -> Int {
        guard dateIndex < eventStartDates.count
            else { return 0 }
        let date = eventStartDates[dateIndex]
        return eventsByDate[date]?.count ?? 0
    }

    /// Returns a event value for the giving section and row
    func event(section: Int, row: Int) -> EventType? {
        guard section < eventStartDates.count
            else { return nil }
        let date = eventStartDates[section]
        guard let events = eventsByDate[date],
            row < events.count
            else { return nil }
        return events[row]
    }
    
    /// Process the given events by sorting and finding conflicts
    mutating func processEvents(events: [EventType]) -> [EventType] {
        guard events.count > 1 else { return events }
        return processEvents(events)
    }
    
    /// Replace the View model values with the given events.
    /// - parameter events: An array of event value
    mutating func update(with events: [EventType]) {
        var newEventsByDate = [Date: [EventType]]()
        processEvents(events: events).forEach { event in
            var eventsPerDay = newEventsByDate[event.startDate] ?? [EventType]()
            eventsPerDay.append(event)
            newEventsByDate[event.startDate] = eventsPerDay
        }
        eventStartDates = newEventsByDate.keys.sorted()
        eventsByDate = newEventsByDate
    }
    
    mutating func addConflict(event1: EventType, event2: EventType) {
        if var conflict = conflicts[event1] {
            conflict.insert(event2)
        } else {
            conflicts[event1] = Set<EventType>([event2])
        }
        
        if var conflict2 = conflicts[event2] {
            conflict2.insert(event1)
        } else {
            conflicts[event2] = Set<EventType>([event1])
        }
    }
    
    func hasConflict(_ event: EventType) -> Bool {
        return conflictForEvent(event)?.count ?? 0 > 0
    }
    
    func conflictForEvent(_ event: EventType) -> Set<EventType>? {
        return conflicts[event]
    }
}

/**
 * ViewModel using Nested Loops to find out overlaps.
 * The reason this was made to be struct because conflicts are cacluated at init time.
 * There is no reason for us not using a Value type.
 */
struct NestedLoopsViewModel: EventsViewModel {

    typealias EventType = DefaultEvent

    var eventStartDates = [Date]()
    var eventsByDate = [Date: [EventType]]()
    var conflicts = [EventType: Set<EventType>]()
}

extension NestedLoopsViewModel {
    
    /* Process the given array of events and updates the conflicted events.
     Time complexisty:
     (n-1) + (n-2) + (n-3) + ..... + 3 + 2 + 1
     Sum = n(n-1)/2
     Hence the time complexity is O(n2)
     */
    mutating func processEvents(_ events: [EventType]) -> [EventType] {
        var sorted = events.sorted { $0.start < $1.start }
        for index1 in 0..<sorted.count {
            for index2 in index1+1..<sorted.count {
                let event1 = sorted[index1]
                let event2 = sorted[index2]
                if event1.end > event2.start {
                    addConflict(event1: event1, event2: event2)
                }
            }
        }
        return sorted
    }
}

/**
 * ViewModel using the Interval Tree to find out overlaps.
 * The reason this was made to be class because the conflicts are looked up as needed;
 * therefore, variable conflicts is mutated N time after it is initialized so it is
 * better to use a reference type instead of a value time where the values are copied.
 */
class TreeEventsViewModel: EventsViewModel {
    typealias EventType = DefaultEvent
    
    var eventStartDates = [Date]()
    var eventsByDate = [Date: [EventType]]()
    var conflicts = [EventType: Set<EventType>]()
    private var tree = IntervalTreeEnum<DefaultIntervalItem<Date, EventType>>()
}

extension TreeEventsViewModel {
    
    /// Return the conflict events for the given event.
    /// It looks up from local cached first, if not found lookup from the tree
    /// The time complixity for this is nLog(n) as the complixity for IntervalTree is
    /// nLog(n)
    func conflictForEvent(_ event: EventType) -> Set<EventType>? {
        if let conflict = conflicts[event] {
            return conflict
        } else {
            let interval = DefaultIntervalItem<Date, EventType>(event.start, event.end)
            let conflict = tree.overlaps(interval)
            var eventConflicts = Set<EventType>()
            for conf in conflict {
                if let eventVal = conf.value, eventVal != event {
                    eventConflicts.insert(eventVal)
                }
            }
            conflicts[event] = eventConflicts
            return eventConflicts
        }    }
    
    /// Return the sorted events after insert events in IntervalTree.
    func processEvents(_ events: [EventType]) -> [EventType] {
        for event in events {
            let interval = DefaultIntervalItem(event.start, event.end, event)
            tree.insert(interval)
        }
        
        var sorted = [EventType]()
        for item in tree.compactMap() {
            if let event = item.value {
                sorted.append(event)
            }
        }
        return sorted
    }
}


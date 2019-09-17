//
//  EventModel.swift
//  events
//
//  Created by Mei Yu on 9/2/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

/**
 * Model for event.
 */
protocol EventModel: Codable, Hashable {

    /// title of event
    var title: String { get set }

    /// start time
    var start: Date { get set }

    /// end time
    var end: Date { get set }

}

extension EventModel {

    /// Returns the start date without time components.
    var startDate: Date { return start.dateWithoutTime()}

}

/// Any Event
struct DefaultEvent: EventModel {
    var title: String
    var start: Date
    var end: Date

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case start = "start"
        case end = "end"
    }
    
    init(title: String,
         start: Date,
         end: Date) {
        self.title = title
        self.start = start
        self.end = end
    }
}

extension DefaultEvent: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(start)
        hasher.combine(end)
    }
}

// MARK: Other Extensions

extension Date {

    /// Returns a date for self without the time components.
    func dateWithoutTime() -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let startOfDate = calendar.startOfDay(for: self)
        return startOfDate
    }

    /// Returns a string formated using eventFormatter
    var longEventStr: String { return DateFormatter.longEventFormatter.string(from: self) }

    /// Returns a string formated using eventFormatter
    var eventStr: String { return DateFormatter.eventFormatter.string(from: self) }
    
    /// Returns a string formated using short eventFormatter
    var shortEventStr: String { return DateFormatter.shortEventFormatter.string(from: self) }

}

extension DateFormatter {

    /// Returns a date formated for the event date with time components
    static let longEventFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy h:mm a"
        return formatter
    }()
    
    static let eventFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd h:mm a"
        return formatter
    }()

    /// Returns a date formated for the event date without time components
    static let shortEventFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
}

extension Decodable {

    /// Decodes an EventModel type from the given JSON representation.
    ///
    /// - parameter data: The data to decode from.
    /// - returns: A value of EventModel type.
    /// - throws: errors from JSONDecoder.decode
    static func decodeEvent<T : Decodable>(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(.longEventFormatter)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed to decode")
            throw error
        }
    }
}

extension Encodable {

    /// Returns a JSON-encoded representation of an EventModel value
    ///
    /// - returns: A new `Data` value containing the encoded JSON data.
    /// - throws: errors from JSONEncoder.encode
    func encodeEvent() throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy  = .formatted(.longEventFormatter)
        do {
            return try encoder.encode(self)
        } catch {
            print("Failed to encode")
            throw error
        }
    }
}

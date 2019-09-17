//
//  IntervalTreeEnum.swift
//  events
//
//  This is an implementation of an Augmented Interval Tree using eunm
//  Algorithm was found at: https://en.wikipedia.org/wiki/Interval_tree#Augmented_tree
//  Created by Mei Yu on 9/14/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

/// The element for each interval
protocol IntervalItem: Comparable {
    associatedtype RangeType: Comparable
    associatedtype ValueType
    
    /// start of range
    var start: RangeType { get set }
    
    /// end of range
    var end: RangeType { get set }
    
    /// max end
    var maxEnd: RangeType { get set }
    
    /// the value for the range
    var value: ValueType? { get set }
}

/// default concrete type for IntervalItem
struct DefaultIntervalItem <T: Comparable, V>: IntervalItem {
    typealias RangeType = T
    typealias ValueType = V
    var start: RangeType
    var end: RangeType
    var maxEnd: RangeType
    var value: ValueType? = nil
    
    /// Initializes a DefaultIntervalItem for storing value
    ///
    /// - Parameters:
    ///   - start: the start of the interval
    ///   - end: the start of the interval
    ///   - value: the value for the given interval
    init (_ start: RangeType, _ end: RangeType, _ value: ValueType) {
        self.start = start
        self.end = end
        self.maxEnd = end
        self.value = value
    }

    /// Initializes a DefaultIntervalItem for search
    ///
    /// - Parameters:
    ///   - start: the start of the interval
    ///   - end: the start of the interval
    ///   - value: the value for the given interval

    init (_ start: RangeType, _ end: RangeType) {
        self.start = start
        self.end = end
        self.maxEnd = end
    }
}

extension DefaultIntervalItem: Comparable {

    static func ==(lhs: DefaultIntervalItem<T, V>, rhs: DefaultIntervalItem<T, V>) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
    static func >(lhs: DefaultIntervalItem<T, V>, rhs: DefaultIntervalItem<T, V>) -> Bool {
        return lhs.start > rhs.start
    }
    
    static func >=(lhs: DefaultIntervalItem<T, V>, rhs: DefaultIntervalItem<T, V>) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    static func <(lhs: DefaultIntervalItem<T, V>, rhs: DefaultIntervalItem<T, V>) -> Bool {
        return lhs.start < rhs.start
    }
    
    static func <=(lhs: DefaultIntervalItem<T, V>, rhs: DefaultIntervalItem<T, V>) -> Bool {
        return lhs < rhs || lhs == rhs
    }
}

extension DefaultIntervalItem: CustomStringConvertible {
    
    var description: String {
        let desc = "\(start)-\(end), max: \(maxEnd))"
        return desc
    }
}

/// Enum implementation of the Augmented Interval Tree
indirect enum IntervalTreeEnum<I: IntervalItem> {
    
    typealias Child = IntervalTreeEnum<I>
    typealias LeftChild = Child
    typealias RightChild = Child
    
    case empty
    case leaf(I)
    case node(I, LeftChild?, RightChild?)

    init(){
        self = .empty;
    }
}

// MARK: Public methods
extension IntervalTreeEnum {
    
    /// Insert a new item to the tree
    @discardableResult
    mutating func insert(_ newItem: I) -> Child {
        
        /// updte the max end of the item using the new item's end.
        func updateMax(newItem: I, item: inout I) {
            if newItem.end > item.maxEnd {
                item.maxEnd = newItem.end
            }
        }
        
        switch self {
        case .empty:
            self = .leaf(newItem)
        case .leaf(var item):
            updateMax(newItem: newItem, item: &item)
            self = newItem < item
                ? .node(item, .leaf(newItem), nil)
                : .node(item, nil, .leaf(newItem))
        case .node(var element, var left, var right):
            updateMax(newItem: newItem, item: &element)
            self = newItem < element
                ? .node(element, left?.insert(newItem) ?? .leaf(newItem), right)
                : .node(element, left, right?.insert(newItem) ?? .leaf(newItem))
        }
        return self
    }
    
    /// Travese the tree with given order
    func travese(order: TraveseOrder, _ body: (I) -> Void) {
        switch self {
        case .empty:
            return
        case .leaf(let item):
            body(item)
        case .node(let item, let left, let right):
            switch order {
            case .preorder:
                body(item)
                left?.travese(order: order, body)
                right?.travese(order: order, body)
            case .inorder:
                left?.travese(order: order, body)
                body(item)
                right?.travese(order: order, body)
            case .postorder:
                left?.travese(order: order, body)
                right?.travese(order: order, body)
                body(item)
            }
        }
    }
    
    /// Return all the overlaps for the given interval
    ///
    /// - Parameters:
    ///   - interval: interval to be overlapped
    func overlaps(_ interval: I) -> [I] {
        var result = [I]()
        overlaps(result: &result, interval)
        return result
    }
    
    /// Return all items stored in the tree
    func compactMap() -> [I] {
        var allItems = [I]()
        travese(order: .inorder) { (item) in
            allItems.append(item)
        }
        return allItems
    }
}

private extension IntervalTreeEnum {
   
    private func overlaps(_ item1: I, _ item2: I) -> Bool {
        return  item1.start < item2.end && item1.end > item2.start
    }
    
    private func overlaps(result: inout [I], _ interval: I) {
        switch self {
        case .empty:
            return
        case .leaf(let item):
            if overlaps(item, interval) {
                result.append(item)
            }
        case .node(let item, let left, let right):
            if overlaps(item, interval) {
                result.append(item)
            }
            
            if let max = left?.max, max >= interval.start {
                left?.overlaps(result: &result, interval)
            }
            
            right?.overlaps(result: &result, interval)
        }
    }
    
    private var max: I.RangeType? {
        switch self {
        case .empty:
            return nil
        case .leaf(let item):
            return item.maxEnd
        case .node(let item, _, _):
            return item.maxEnd
        }
    }
}

extension IntervalTreeEnum: CustomStringConvertible {
    var description: String {
        var desc = ""
        travese(order: .inorder) { (element) in
            desc += "[ \(element)]"
        }
        return desc
    }
}

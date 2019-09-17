//
//  IntervalTreeStruct.swift
//  events
//
//  This is my first implementation of an Augmented Interval Tree using struct and class.
//  It is not being used by the UI.
//  Created by Mei Yu on 9/14/19.
//  Copyright © 2019 mei. All rights reserved.
//

import Foundation

class IntervalNode<T: Comparable, E> {
    let start: T
    let end: T
    var max: T   // max end of items on the left
    let element: E?
    
    var left: IntervalNode<T, E>?
    var right: IntervalNode<T, E>?
    
    init(start: T, end: T, element: E? = nil) {
        precondition(start <= end)
        
        self.start = start
        self.end = end
        self.max = end
        self.element = element
    }
}

extension IntervalNode: Comparable {
    
    static func ==(lhs: IntervalNode<T, E>, rhs: IntervalNode<T, E>) -> Bool {
        return lhs.start == rhs.start && lhs.end == rhs.end
    }
    
    static func >(lhs: IntervalNode<T, E>, rhs: IntervalNode<T, E>) -> Bool {
        return lhs.start > rhs.start
    }
    
    static func >=(lhs: IntervalNode<T, E>, rhs: IntervalNode<T, E>) -> Bool {
        return lhs > rhs || lhs == rhs
    }
    
    static func <(lhs: IntervalNode<T, E>, rhs: IntervalNode<T, E>) -> Bool {
        return lhs.start < rhs.start
    }
    
    static func <=(lhs: IntervalNode<T, E>, rhs: IntervalNode<T, E>) -> Bool {
        return lhs < rhs || lhs == rhs
    }
}

extension IntervalNode: CustomStringConvertible {
    
    var description: String {
        var s = "["
        if let left = left {
            s += "\(left)"
        }
        
        s += "(\(start),\(end)):{\(max)}"
        
        if let right = right {
            s += "\(right)"
        }
        return s + "]"
    }
}

struct IntervalTreeStruct<T: Comparable, E> {
    
    private (set) var root: IntervalNode<T, E>? = nil
}
// MARK: Public Methods
extension IntervalTreeStruct {
    
    var description: String {
        return root?.description ?? "empty"
    }
    
    mutating func insert(_ node: IntervalNode<T, E>) {
        root = insert(root, node)
    }
    
    func overlaps(start: T,
                  end: T) -> [IntervalNode<T, E>] {
        var result = [IntervalNode<T, E>]()
        overlaps(result: &result, node: root, interval: IntervalNode(start: start, end: end))
        return result
    }
}

// MARK: Private Methods
private extension IntervalTreeStruct {
    
    func overlaps(result: inout [IntervalNode<T, E>],
                  node: IntervalNode<T, E>?,
                  interval: IntervalNode<T, E>) {
        
        guard let node = node else { return }
        
        if  node.start < interval.end && node.end > interval.start {
            result.append(node)
        }
        
        if let left = node.left, left.max >= interval.start {
            overlaps(result: &result, node: left, interval: interval)
        }
        overlaps(result: &result, node: node.right, interval: interval)
    }
    
    @discardableResult
    func insert(_ node: IntervalNode<T, E>?,
                _ newNode: IntervalNode<T, E>) -> IntervalNode<T, E> {
        
        guard let node = node else { return newNode }
        
        if newNode.end > node.max {
            node.max = newNode.end
        }
        
        if (node < newNode) {
            if node.right == nil {
                node.right = newNode
            } else {
                insert(node.right, newNode)
            }
        } else {
            if node.left == nil {
                node.left = newNode
            } else {
                insert(node.left, newNode)
            }
        }
        return node
    }
    
    func overlaps(with interval: IntervalNode<T, E>) -> [IntervalNode<T, E>]{
        var result = [IntervalNode<T, E>]()
        overlaps(result: &result, node: root, interval: interval)
        return result
    }
}

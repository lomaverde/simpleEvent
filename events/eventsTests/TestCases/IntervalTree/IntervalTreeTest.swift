//
//  AugmentedIntervalTreeTest.swift
//  eventsTests
//
//  Created by Mei Yu on 9/13/19.
//  Copyright © 2019 mei. All rights reserved.
//

import XCTest
@testable import events

struct TestElement {
    let start: Int
    let end: Int
    let name: String
}

class IntervalTreeTest: XCTestCase {
   
    func testOverlap2() {
        let testElements: [TestElement]  = [
            TestElement(start: 5, end: 6, name: "element 1"),
            TestElement(start: 1, end: 5, name: "element 2"),
            TestElement(start: 2, end: 3, name: "element 2"),
            TestElement(start: 15, end: 25, name: "element 3"),
            TestElement(start: 11, end: 12, name: "element 4"),
            TestElement(start: 8, end: 16, name: "element 5"),
            TestElement(start: 14, end: 20, name: "element 6"),
            TestElement(start: 18, end: 200, name: "element 7"),
            TestElement(start: 2, end: 8, name: "element 8")
        ]
        
        var tree = IntervalTreeEnum<DefaultIntervalItem<Int, TestElement>>()
        
        for elm in testElements {
            let interval = DefaultIntervalItem(elm.start, elm.end, elm)
            tree.insert(interval)
        }
        
        print ("\(tree)")
        
        let conflicts = tree.overlaps(DefaultIntervalItem(8,10))
        XCTAssertTrue(conflicts.count == 1)
        
        let conflicts2 = tree.overlaps(DefaultIntervalItem(1,8))
        XCTAssertTrue(conflicts2.count == 4)
    }
    
    func testOverlap() {
        let testElements: [TestElement]  = [
                TestElement(start: 5, end: 6, name: "element 1"),
                TestElement(start: 1, end: 5, name: "element 2"),
                TestElement(start: 2, end: 3, name: "element 2"),
                TestElement(start: 15, end: 25, name: "element 3"),
                TestElement(start: 11, end: 12, name: "element 4"),
                TestElement(start: 8, end: 16, name: "element 5"),
                TestElement(start: 14, end: 20, name: "element 6"),
                TestElement(start: 18, end: 200, name: "element 7"),
                TestElement(start: 2, end: 8, name: "element 8")
            ]
        
        var tree = IntervalTreeStruct<Int,TestElement>()
        
        for elm in testElements {
            tree.insert(IntervalNode<Int, TestElement>(start: elm.start, end: elm.end, element: elm))
        }
        
        print ("\(tree)")
        
        let conflicts = tree.overlaps(start: 8, end: 10)
        XCTAssertTrue(conflicts.count == 1)

        let conflicts2 = tree.overlaps(start: 1, end: 8)
        XCTAssertTrue(conflicts2.count == 4)
    }
}

//
//  TestAbcTests.swift
//  TestAbcTests
//
//  Created by MJ Lee on 2019/8/13.
//  Copyright © 2019 MJ Lee. All rights reserved.
//

import XCTest
@testable import TestAbc

class TestAbcTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        XCTAssert(MathTool.sum(10, 20) == 30)
        XCTAssert(MathTool.sum(1, 2) == 5)
        XCTAssert(MathTool.sum(10, 20) == 30)
        XCTAssert(MathTool.sum(10, 20) == 30)
        XCTAssert(MathTool.sum(10, 20) == 30)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}

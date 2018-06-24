//
//  LinearInterpolationTests.swift
//  PixelAnimGeneratorTests
//
//  Created by Charlie Williams on 24/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import XCTest
@testable import PixelAnimGenerator

class LinearInterpolationTests: XCTestCase {
    
    func testHalfwayGoingToBiggerRange() {
        XCTAssertEqual(5.lerp(from: 0, to: 10, out1: 0, out2: 100), 50)
    }

    func testHalfwayGoingToSmallerRange() {
        XCTAssertEqual(50.lerp(from: 0, to: 100, out1: 0, out2: 10), 5)
    }

    func testTenPercent() {
        XCTAssertEqual(1.lerp(from: 0, to: 10, out1: 0, out2: 100), 10)
    }

    func testNinetyFivePercent() {
        XCTAssertEqual(95.lerp(from: 0, to: 100, out1: 0, out2: 10), 9.5)
    }

    func testClampsByDefault() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, out1: 0, out2: 100), 100)
    }

    func testClampsWhenExplicitlyToldTo() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, out1: 0, out2: 100, clamp: true), 100)
    }

    func testDoesNotClampWhenExplicitlyToldNotTo() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, out1: 0, out2: 100, clamp: false), 110, accuracy: 0.00001)
    }

    func testReversedOutput() {
        XCTAssertEqual(1.lerp(from: 0, to: 10, out1: 100, out2: 0), 90)
    }

    // TODO support negatives
    
//    func testNegativeIn() {
//        XCTAssertEqual(-5.lerp(from: 0, to: -10, out1: 0, out2: 100), 50)
//    }
//
    func testNegativeOut() {
        XCTAssertEqual(5.lerp(from: 0, to: 10, out1: -100, out2: 0), -50)
    }
//
//    func testNegativeBoth() {
//        XCTAssertEqual(-5.lerp(from: -10, to: 0, out1: -100, out2: 0), -50)
//    }
//
    func testClampsNegative() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, out1: 0, out2: -100, clamp: true), -100)
    }

    func testDoesNotClampNegative() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, out1: 0, out2: -100, clamp: false), -110, accuracy: 0.00001)
    }
}

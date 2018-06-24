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
        XCTAssertEqual(5.lerp(from: 0, to: 10, min: 0, max: 100), 50)
    }

    func testHalfwayGoingToSmallerRange() {
        XCTAssertEqual(50.lerp(from: 0, to: 100, min: 0, max: 10), 5)
    }

    func testTenPercent() {
        XCTAssertEqual(1.lerp(from: 0, to: 10, min: 0, max: 100), 10)
    }

    func testNinetyFivePercent() {
        XCTAssertEqual(95.lerp(from: 0, to: 100, min: 0, max: 10), 9.5)
    }

    func testClampsByDefault() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, min: 0, max: 100), 100)
    }

    func testClampsWhenExplicitlyToldTo() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, min: 0, max: 100, clamp: true), 100)
    }

    func testDoesNotClampWhenExplicitlyToldNotTo() {
        XCTAssertEqual(11.lerp(from: 0, to: 10, min: 0, max: 100, clamp: false), 110, accuracy: 0.00001)
    }

    // TODO support negatives
    
//    func testNegativeIn() {
//        XCTAssertEqual(-5.lerp(from: 0, to: -10, min: 0, max: 100), 50)
//    }
//
//    func testNegativeOut() {
//        XCTAssertEqual(5.lerp(from: 0, to: 10, min: -100, max: 0), -50)
//    }
//
//    func testNegativeBoth() {
//        XCTAssertEqual(-5.lerp(from: -10, to: 0, min: -100, max: 0), -50)
//    }
//
//    func testClampsNegative() {
//
//    }
//
//    func testDoesNotClampNegative() {
//
//    }
}

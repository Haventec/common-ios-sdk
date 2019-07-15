//
//  BackwardsCompatibleTest.swift
//  HaventecCommon_Tests
//
//  Created by Clifford Phan on 3/7/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

import XCTest
import HaventecCommon

class BackwardsCompatibleTest: XCTestCase {
    /// Hard Coded values from previous version
    let previousPin: String = "1234"
    let previousSaltBytes: [UInt8] = [50, 68, 32, 43, 25, 62, 104, 12, 1, 102, 93, 48, 8, 97, 125, 103, 55, 46, 66, 49, 54, 95, 90, 78, 70, 6, 126, 107, 118, 83, 127, 96, 88, 86, 71, 9, 115, 119, 13, 106, 74, 99, 122, 36, 38, 62, 53, 46, 34, 96, 28, 14, 20, 48, 82, 73, 100, 33, 85, 17, 57, 34, 93, 119, 22, 98, 41, 18, 127, 30, 103, 45, 24, 125, 28, 66, 86, 37, 87, 76, 48, 85, 8, 52, 34, 114, 109, 18, 43, 80, 49, 84, 31, 41, 37, 45, 96, 111, 82, 110, 21, 102, 51, 77, 62, 114, 119, 92, 53, 28, 83, 57, 47, 82, 118, 14, 92, 49, 8, 34, 115, 100, 104, 114, 60, 2, 105, 27]
    let previousHashedPin = "EGBI5M+7JMvX8ZcetCcoBw86UuApcNfdrHsDFZ4PW6bojf3zKcqaTNdX+zAxrgysjxPAtvIMaHTlVTithmPaMg=="
    
    func testHashPin() {
        guard let currentHashedPin: String? = try? HaventecCommon.hashPin(saltBytes: previousSaltBytes, pin: previousPin) else { XCTFail(); return }
        XCTAssertEqual(currentHashedPin, previousHashedPin)
    }
}

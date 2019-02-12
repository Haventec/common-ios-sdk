//
//  HaventecHelperTest.swift
//  HaventecCommon_Tests
//
//  Created by Clifford Phan on 30/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import HaventecCommon

class HaventecCommonTest: XCTestCase {
    
    let exceptionThrown = "Haventec Exception was thrown from this call"
    let invalidBase64Format = "String generated isn't in a valid base 64 format"
    let incorrectSize = "Size of test object is incorrect"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateSalt() {
        guard let saltByteArray: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        let salt = String(bytes: saltByteArray, encoding: .utf8)!
        let range = NSRange(location: 0, length: salt.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")

        XCTAssertTrue(regex.firstMatch(in: salt, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testGenerateSalt_Unique() {
        guard let saltA: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        guard let saltB: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        XCTAssert(saltA != saltB)
    }
    
    func testHashPin() {
        let saltBytes: [UInt8] = try! HaventecCommon.generateSalt()

        let hashedPin: String = HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234")
        let range = NSRange(location: 0, length: hashedPin.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
        
        XCTAssertTrue(regex.firstMatch(in: hashedPin, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testHashPin_UniqueHashPins() {
        let saltBytesA: [UInt8] = try! HaventecCommon.generateSalt()
        let saltBytesB: [UInt8] = try! HaventecCommon.generateSalt()
        
        let hashedPinA: String = HaventecCommon.hashPin(saltBytes: saltBytesA, pin: "1234")
        let hashedPinB: String = HaventecCommon.hashPin(saltBytes: saltBytesB, pin: "1234")
        
        XCTAssert(hashedPinA != hashedPinB)
    }
    
    func testHashPin_SamePinAndSalt() {
        let saltBytes: [UInt8] = try! HaventecCommon.generateSalt()
        
        let hashedPinA: String = HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234")
        let hashedPinB: String = HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234")
        
        XCTAssert(hashedPinA == hashedPinB)
    }
    
    func testHashPin_DifferentPinSameSalt() {
        let saltBytes: [UInt8] = try! HaventecCommon.generateSalt()
        
        let hashedPinA: String = HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234")
        let hashedPinB: String = HaventecCommon.hashPin(saltBytes: saltBytes, pin: "3412")
        
        XCTAssert(hashedPinA != hashedPinB)
    }
}

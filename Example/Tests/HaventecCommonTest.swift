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
    let emptyHashPin = "Hashed Pin is empty"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGenerateSalt_ProperLength() {
        guard let saltByteArray: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        XCTAssertEqual(saltByteArray.count, 64)
    }

    func testGenerateSalt_Base64Encoded() {
        guard let saltByteArray: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        let salt = Data(saltByteArray).base64EncodedString()
        
        let range = NSRange(location: 0, length: salt.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")

        XCTAssertTrue(regex.firstMatch(in: salt, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testGenerateSalt_UniqueSalts() {
        guard let saltA: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        guard let saltB: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        XCTAssert(saltA != saltB)
    }
    
    func testHashPin_ProperLength() {
        guard let saltBytes: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPin: String = hashedPinOptional else { XCTFail(emptyHashPin); return }
        XCTAssertEqual(hashedPin.count, 88)
    }
    
    func testHashPin_Base64Encoded() {
        guard let saltBytes: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPin: String = hashedPinOptional else { XCTFail(emptyHashPin); return }
        
        let range = NSRange(location: 0, length: hashedPin.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
        
        XCTAssertTrue(regex.firstMatch(in: hashedPin, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testHashPin_Base64Decoded() {
        guard let saltBytes: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPin: String = hashedPinOptional else { XCTFail(emptyHashPin); return }
        
        guard let decodedData = Data(base64Encoded: hashedPin) else { XCTFail(invalidBase64Format); return }
        guard String(data: decodedData, encoding: .utf8) != nil else { return; }
        XCTFail("Decoded base64 byte array shouldn't be able to decode to a utf8 string")
    }
    
    func testHashPin_IncorrectBase64Decoded() {
        let hashedPin: String = "%$^&*"
        
        guard Data(base64Encoded: hashedPin) != nil else { return }
        XCTFail(invalidBase64Format);
    }
    
    func testHashPin_SamePinDifferentSalt() {
        guard let saltBytesA: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        guard let saltBytesB: [UInt8] = try? HaventecCommon.generateSalt() else { XCTFail(exceptionThrown); return }
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytesA, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytesB, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA != hashedPinB)
    }
    
    func testHashPin_SamePinSameSalt() {
        let saltBytes: [UInt8] = try! HaventecCommon.generateSalt()
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA == hashedPinB)
    }
    
    func testHashPin_DifferentPinSameSalt() {
        let saltBytes: [UInt8] = try! HaventecCommon.generateSalt()
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "3412") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA != hashedPinB)
    }
}

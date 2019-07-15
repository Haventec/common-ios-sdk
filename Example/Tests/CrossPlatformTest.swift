//
//  CrossPlatformTest.swift
//  HaventecCommon
//
//  Ensure same salt size and backwards compatibility from changing salt size
//
//  Created by Clifford Phan on 12/6/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import HaventecCommon

class CrossPlatformTest: XCTestCase {
    // Android SDK hardcoded salt values
    let android64SaltByteArrayA = [-125, 116, 108, -117, 43, 106, -59, 64, 6, -94, 18, -60, 92, 40, -95, -40, -46, 20, 4, -35, -54, 24, -122, 71, 83, 117, 40, 103, -4, -51, -1, 66, -71, 24, -74, 106, 44, 64, -127, 102, -68, -73, -78, -30, 100, -99, -101, -78, 63, 44, -20, -51, 22, -95, 41, -58, 1, -26, 125, 32, -28, 122, -75, -123]
    
    let android64SaltByteArrayB = [105, 90, -44, 90, -35, 111, -36, 46, -111, -48, 119, 114, 103, -2, 7, -44, 58, 120, 88, 31, 109, -96, -12, -121, -102, -60, 23, -53, -114, 79, -41, 51, 14, 72, 104, -77, -121, 67, 93, -102, 44, 60, 111, 103, -59, 85, 61, -75, 83, -35, 4, 82, -39, -9, -24, 101, 62, 42, -92, 23, -17, 15, 117, 73]
    
    let android128SaltByteArray = [-92, -17, -43, 67, -10, 32, 61, -37, -22, 87, 105, 50, 6, -32, 23, 97, -72, 39, -19, 34, -87, -1, 4, -50, -81, -21, 101, -38, 83, 84, -117, 58, -104, -47, 20, 41, 13, -66, -61, -110, 55, -119, 26, 67, -42, 39, 60, 30, -15, -45, -88, 69, 21, 1, -74, -66, -102, 96, -99, -125, -19, 118, -81, 50, -10, 28, 127, -22, -64, 102, 115, -63, 69, 109, 111, -61, -93, 58, -116, -97, -19, -70, 121, -45, -123, -67, 29, 69, 79, 89, 80, 25, -94, 26, -34, 104, 58, 99, 14, 46, 17, -9, -72, -46, -88, -98, -68, 68, 33, 57, -41, 93, -18, -52, -79, -41, 91, -36, -16, 109, -81, 94, -98, -37, -111, 117, -95, -63]
    
    let exceptionThrown = "Haventec Exception was thrown from this call"
    let invalidBase64Format = "String generated isn't in a valid base 64 format"
    let incorrectSize = "Size of test object is incorrect"
    let emptyHashPin = "Hashed Pin is empty"
    
    func convertJavaByteArray(saltByte: [Int]) -> [UInt8] {
        var result: [UInt8] = [UInt8](repeating: 0, count: saltByte.count)
        
        // Convert unsigned to 8 bit signed
        for i in 0..<saltByte.count {
            result[i] = UInt8(bitPattern: Int8(Int(saltByte[i])))
        }
        
        // Mock logic in generateSalt - halve the bit values for utf-8 encoding
        result = Array(result)
        
        /// Modify all bytes to be in the correct range for utf8 encoding
        for i in 0..<result.count {
            result[i] = result[i] >> 1
        }
        
        return result
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConsistentConverstion() {
        let android64Salt = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        let android128Salt = convertJavaByteArray(saltByte: android128SaltByteArray)
        
        XCTAssertEqual(android64Salt, convertJavaByteArray(saltByte: android64SaltByteArrayA))
        XCTAssertEqual(android128Salt, convertJavaByteArray(saltByte: android128SaltByteArray))
    }
    
    func testGenerateSalt_ProperLength() {
        let saltByteArray = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        XCTAssertEqual(saltByteArray.count, 64)
    }
    
    func testGenerateSalt_Base64Encoded() {
        let saltByteArray = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
        let salt = Data(saltByteArray).base64EncodedString()
        
        let range = NSRange(location: 0, length: salt.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
        
        XCTAssertTrue(regex.firstMatch(in: salt, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testGenerateSalt_UniqueSalts() {
        let saltA = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        let saltB = convertJavaByteArray(saltByte: android64SaltByteArrayB)
        
        XCTAssert(saltA != saltB)
    }
    
    func testHashPin_ProperLength() {
        let saltBytes = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPin: String = hashedPinOptional else { XCTFail(emptyHashPin); return }
        XCTAssertEqual(hashedPin.count, 88)
    }
    
    func testHashPin_Base64Encoded() {
        let saltBytes = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
        guard let hashedPinOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPin: String = hashedPinOptional else { XCTFail(emptyHashPin); return }
        
        let range = NSRange(location: 0, length: hashedPin.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
        
        XCTAssertTrue(regex.firstMatch(in: hashedPin, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testHashPin_Base64Decoded() {
        let saltBytes = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
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
        let saltBytesA = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        let saltBytesB = convertJavaByteArray(saltByte: android64SaltByteArrayB)
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytesA, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytesB, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA != hashedPinB)
    }
    
    func testHashPin_SamePinSameSalt() {
        let saltBytes = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA == hashedPinB)
    }
    
    func testHashPin_DifferentPinSameSalt() {
        let saltBytes = convertJavaByteArray(saltByte: android64SaltByteArrayA)
        
        guard let hashedPinAOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "1234") else { XCTFail(exceptionThrown); return }
        guard let hashedPinA: String = hashedPinAOptional else { XCTFail(emptyHashPin); return }
        guard let hashedPinBOptional = try? HaventecCommon.hashPin(saltBytes: saltBytes, pin: "3412") else { XCTFail(exceptionThrown); return }
        guard let hashedPinB: String = hashedPinBOptional else { XCTFail(emptyHashPin); return }
        
        XCTAssert(hashedPinA != hashedPinB)
    }

}

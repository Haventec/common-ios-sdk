//
//  HaventecHelperTest.swift
//  HaventecCommon_Tests
//
//  Created by Clifford Phan on 30/1/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import HaventecCommon

class HaventecHelperTest: XCTestCase {
    
    let exceptionThrown = "Haventec Exception was thrown from this call"
    let invalidSalt = "Salt string generated isn't in a valid base 64 format"
    let incorrectSize = "Size of test object is incorrect"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateSalt() {
        let haventec = HaventecHelper()
        let salt = try? haventec.generateSalt(size: 128)
        
        if (salt != nil) {
            let range = NSRange(location: 0, length: salt!.count)
            let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
            
            XCTAssertTrue(regex.firstMatch(in: salt!, options: [], range: range) != nil, invalidSalt)
        }
        else {
            XCTFail(exceptionThrown)
        }
    }
    
    func testDoHash() {
        let haventec = HaventecHelper()
        let saltString = try? haventec.generateSalt(size: 128)
        let shaString: String = haventec.doHash(salt: saltString!, pin: "1234")
        
        
    }
    
//    public func doHash(salt: String, pin: String) -> String {
//        var basePin: String = ""
//        if let dataPin = salt.data(using: .utf8) {
//            basePin = dataPin.base64EncodedString()
//        }
//
//        let saltString: String = salt + basePin;
//
//        let shaString: String = sha512Base64(instring: saltString)
//
//        return shaString
//    }
}

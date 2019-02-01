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
    let invalidBase64Format = "String generated isn't in a valid base 64 format"
    let incorrectSize = "Size of test object is incorrect"

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGenerateSalt() {
        let haventec = HaventecHelper()
        
        if let salt: String = try? haventec.generateSalt(size: 128) {
            let range = NSRange(location: 0, length: salt.count)
            let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
            
            XCTAssertTrue(regex.firstMatch(in: salt, options: [], range: range) != nil, invalidBase64Format)
        } else {
            XCTFail(exceptionThrown)
        }
    }
    
    func testHashPin() {
        let haventec = HaventecHelper()
        let salt: String = try! haventec.generateSalt(size: 128)
        
        let hashedPin: String = haventec.hashPin(salt: salt, pin: "1234")
        let range = NSRange(location: 0, length: hashedPin.count)
        let regex = try! NSRegularExpression(pattern: "^[A-Za-z0-9+\\/=]{1,}$")
        
        XCTAssertTrue(regex.firstMatch(in: hashedPin, options: [], range: range) != nil, invalidBase64Format)
    }
    
    func testSameSaltWithDifferentPin() {
        let haventec = HaventecHelper()
        let salt = "azNsWEHCusKhw7RRwr7CosOkw6PCnlzCkW7CvBrDlTtzdsOGTsKFw6vDk8Kow73Dhg8QBsOJDXPCnsKdw7jCoMKGAsOXMcKqH8KNRhvCtRhDw6bDticFAsOBwosEwrzCmxbDrcKpwrY5PTrCoiLDjsO3H3hlwpLChQAVV8Kjw4kIbRDDk8OWwrHDpEbCgsKRw5fCkmfDmnF0NMOcwooXQ8KXw4c3woJsw5pyYTjDvcOrRcKqw5BWw45OHsKlwoLCmSnCnsKGwqlNG146TX/Do3Buw47Dg3cUw5bCgivDlMODw7AZwrjDqzdbw5AcHD7Dk38tUsO1DcOtw4pmPHPDtHVBw4sFFsKsZDMBdsO6djnCg8Kjw7gsMkZSw4vCrU9iPk3DhWUCw597w4fDksKUajXCgsKFeB3DncODQyQgwq/ClsOoc8ORw7Npw5bDicOHSVp6wqw7wq7Cv0c2w7TClX56CcKpwqTChyDDusOdIgHDo1HDisObRxfDhiLDrsOZw5bCr8OZwrHCnywkEsO3WcOuNMKcworDslfDisOZW8KDwpBPE8OEw5/Dh0QTBMK1NMOyw67CnMKLJ0FVdcOvwr8fw4gEwq5UwpBbCU4Kwo/CvsO5AHUpSsKzOMKhw48DPcOHwp3CigUsw4ErDETCnh0ZZwopZMKGE0JHwo5KV8OoWTMPCWnCn8O1w5TDvmHCtSDCk8OZwrkuwoDCjcOEwqzDpMKRwqI2w7nDp1owAsO1Ri96EcOCw5HDqQDDk2nCoMO6LMOgW13DsMK4CkfDmCXDtsO9T1HDjkARAGsewrs6w6jCrcO4Y8KuX1lIworDmMKmw69VasOYw7Aaw65Xw7TCsMOrw4PCtMOvwoHCpsOTwo3DtEYCXVdJwoXDhcKCVh4ow5dPacKIMsOwdid8NcOCw5/CgDhzZsOGV8OXwrnDrsOiw5x3wpTCllzDiFPDhSbDiMK9ScOuNcKbRUd6wrVAw4zCmcKdcBHChHl3w5YJw6JGJsKCP09BO1MJ"
        
        let hashedPinA: String = haventec.hashPin(salt: salt, pin: "1234")
        let hashedPinB: String = haventec.hashPin(salt: salt, pin: "7890")
        
        if hashedPinA != hashedPinB {
            XCTFail()
        }
    }
}

//
//  AddDeviceResponse.swift
//  HaventecCommon_Example
//
//  Created by Clifford Phan on 2/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct AddDeviceResponse : Codable {
    var userEmail: String
    var activationToken: String
    var deviceUuid: String
    var mobileNumber: String?
    fileprivate var responseStatus: ResponseStatus
}

private struct ResponseStatus: Codable {
    var status, message, code: String
}

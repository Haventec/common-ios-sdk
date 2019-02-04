//
//  ActivateDeviceResponse.swift
//  HaventecCommon_Example
//
//  Created by Clifford Phan on 2/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct ActivateDeviceResponse: Codable {
    var accessToken: AccessToken
    var authKey: String
    fileprivate var responseStatus: ResponseStatus
}

struct AccessToken: Codable {
    var token, type: String
}

private struct ResponseStatus: Codable {
    var code, message, status: String
}

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
    var responseStatus: ResponseStatus
}

struct AccessToken: Codable {
    var token, type: String
}

//
//  AddDeviceRequest.swift
//  HaventecCommon_Example
//
//  Created by Clifford Phan on 2/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct AddDeviceRequest : Codable {
    var applicationUuid: String
    var apiKey: String
    var haventecUsername: String
    var haventecEmail: String
}

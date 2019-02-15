//
//  ResponseStatus.swift
//  HaventecCommon_Example
//
//  Created by Clifford Phan on 15/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

struct ResponseStatus: Codable {
    var status, message, code: String
}

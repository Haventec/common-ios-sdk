//
//  CommonErrorCodes.swift
//  HaventecCommon
//
//  Created by Justin Crosbie on 15/3/19.
//

import Foundation

public enum CommonErrorCodes: String {
    case randomByteFailure = "Failure in generating random bytes"
    case incorrectSaltLength = "Failure in decoding the salt byte array due to incorrect length"
    case nonUtf8EncodingFormat = "Failure in decoding the salt byte array due to incorrect range of byte values for decoding to a utf8 string"
}

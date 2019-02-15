//
//  HashingHelper.swift
//  HaventecCommon
//
//  Created by Clifford Phan on 14/2/19.
//

import Foundation
import CommonCrypto

/// Helper class for hashing related functions for the HaventecCommon module
class HashingHelper {
    private static let saltByteSize: Int = 128
    
    /// The exceptions that can be thrown from the HaventecCommon Module
    ///
    /// - generateSalt: Internal error that occurs in memory when random bytes can't be stored in a buffer
    /// - hashPin: Errors relating to hashing the salt and the pin mostly regarding the salt byte array
    enum HaventecCommonException: Error {
        case generateSalt(String)
        case hashPin(String)
    }
    
    enum CommonErrorCodes: String {
        case randomByteFailure = "Failure in generating random bytes"
        case incorrectSaltLength = "Failure in decoding the salt byte array due to incorrect length"
        case nonUtf8EncodingFormat = "Failure in decoding the salt byte array due to incorrect range of byte values for decoding to a utf8 string"
    }
    
    /// Generates a random byte array representing the salt
    ///
    /// - Returns: Byte array representing a Base64 salted string
    public static func generateSalt() throws -> [UInt8] {
        /// New Salt of size 128 bytes
        var keyData = Data(count: saltByteSize)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, saltByteSize, $0)
        }
        
        if result == errSecSuccess {
            var correctResult: [UInt8] = Array(keyData)
            
            /// Modify all bytes to be in the correct range for utf8 encoding
            for i in 0..<correctResult.count {
                correctResult[i] = correctResult[i] >> 1
            }
            
            return correctResult
        } else {
            throw HaventecCommonException.generateSalt(CommonErrorCodes.randomByteFailure.rawValue)
        }
    }
    
    /// Generates a hashed PIN that's essential to using Authenticate & Sanctum
    ///
    /// - Parameters:
    ///   - saltBytes: Byte array representing a Base64 salted string
    ///   - pin: String representing the user's PIN
    /// - Returns: Hashed PIN of the correct format required for Authenticate & Sanctum
    public static func hashPin(saltBytes: [UInt8], pin: String) throws -> String? {
        /// Validate the salt byte array
        if (saltBytes.count != saltByteSize) {
            throw HaventecCommonException.hashPin(CommonErrorCodes.incorrectSaltLength.rawValue)
        }
        if (!saltBytes.allSatisfy({0 <= $0 && $0 <= 127})) {
            throw HaventecCommonException.hashPin(CommonErrorCodes.nonUtf8EncodingFormat.rawValue)
        }
        
        let salt: String = String(bytes: saltBytes, encoding: .utf8)!
        guard let data = (salt + pin).data(using: .utf8) else { return nil }
        
        /// Get Digest
        let dataNS = data as NSData
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        
        CC_SHA512(dataNS.bytes, UInt32(dataNS.length), &digest)
        
        /// Return base 64 encoded digest
        return Data(digest).base64EncodedString()
    }
}

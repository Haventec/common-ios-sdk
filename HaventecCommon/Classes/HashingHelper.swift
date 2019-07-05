//
//  HashingHelper.swift
//  HaventecCommon
//
//  Created by Clifford Phan on 14/2/19.
//

import Foundation
import CryptoSwift

/// Helper class for hashing related functions for the HaventecCommon module
class HashingHelper {
    private static let prevSaltByteSize: Int = 128
    private static let saltByteSize: Int = 64
    
    /**
     Generates a random byte array representing the salt
     
     - Throws: HaventecCommonException.generateSalt
        - If internal error generating the random bytes into memory
     
     - Returns: Byte array representing a Base64 salted string
    */
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
            throw HaventecCommon.HaventecCommonException.generateSalt(CommonErrorCodes.randomByteFailure.rawValue)
        }
    }
    
    /**
     Generates a hashed PIN that's essential to using Authenticate & Sanctum
     
     - Parameters:
        - saltBytes: Byte array representing a Base64 salted string
        - pin: String representing the user's PIN
     
     - Throws: HaventecCommonException.hashPin
        - If salt size is invalid
        - If the salt bye array has invalid values
     
     - Returns: Hashed PIN of the correct format required for Authenticate & Sanctum
     */
    public static func hashPin(saltBytes: [UInt8], pin: String) throws -> String? {
        /// Validate the salt byte array
        if (saltBytes.count != saltByteSize && saltBytes.count != prevSaltByteSize) {
            throw HaventecCommon.HaventecCommonException.hashPin(CommonErrorCodes.incorrectSaltLength.rawValue)
        }
        if (!saltBytes.allSatisfy({0 <= $0 && $0 <= 127})) {
            throw HaventecCommon.HaventecCommonException.hashPin(CommonErrorCodes.nonUtf8EncodingFormat.rawValue)
        }
        
        guard let pinData: Data = pin.data(using: .utf8) else { return nil }
        let pinBytes:[UInt8] = [UInt8](pinData)
        do {
            var digest = SHA2(variant: .sha512)
            try digest.update(withBytes: saltBytes)
            try digest.update(withBytes: pinBytes)
            let result = try digest.finish()
            
            /// Return base 64 encoded digest
            return Data(result).base64EncodedString()
        } catch {
            return nil;
        }
    }
}

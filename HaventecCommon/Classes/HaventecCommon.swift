import Foundation
import CommonCrypto

/// Non-instantial class providing common functions for the Authenticate & Sanctum API
public class HaventecCommon {
    /**
     Generates a random byte array representing the salt
     
     - Throws: HaventecCommonException.generateSalt
        - If internal error generating the random bytes into memory
     
     - Returns: Byte array representing a Base64 salted string
     */
    public static func generateSalt() throws -> [UInt8] {
        return try HashingHelper.generateSalt()
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
        return try HashingHelper.hashPin(saltBytes: saltBytes, pin: pin)
    }
}

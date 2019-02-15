import Foundation
import CommonCrypto

/// Non-instantial class providing common functions for the Authenticate & Sanctum API
public class HaventecCommon {
    /// Generates a random byte array representing the salt
    ///
    /// - Returns: Byte array representing a Base64 salted string
    public static func generateSalt() throws -> [UInt8] {
        return try HashingHelper.generateSalt()
    }
    
    /// Generates a hashed PIN that's essential to using Authenticate & Sanctum
    ///
    /// - Parameters:
    ///   - saltBytes: Byte array representing a Base64 salted string
    ///   - pin: String representing the user's PIN
    /// - Returns: Hashed PIN of the correct format required for Authenticate & Sanctum
    public static func hashPin(saltBytes: [UInt8], pin: String) throws -> String? {
        return try HashingHelper.hashPin(saltBytes: saltBytes, pin: pin)
    }
}

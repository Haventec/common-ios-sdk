import Foundation
import CommonCrypto


/// Non-instantial class providing common functions for the Authenticate & Sanctum API
public class HaventecCommon {
    static let saltByteSize: Int = 128
    
    /// Generates a random salt string that is encoded in base64
    ///
    /// - Returns: Byte array representing a Base64 salted string
    public static func generateSalt() -> [UInt8] {
        var saltArray: [Int32] = []
        
        /// Generate random bytes
        for _ in 0..<saltByteSize {
            var intOut: Int32 = 0;
            
            var bytes = [Int32](repeating: Int32(0), count: 4)
            let statusCode = CCRandomGenerateBytes(&bytes, bytes.count)
            
            if statusCode == CCRNGStatus(kCCSuccess) {
                let data = NSData(bytes: bytes, length: bytes.count)
                data.getBytes(&intOut, length: MemoryLayout<Int32>.size)
                saltArray.append(intOut);
            } else {
                preconditionFailure("Failure in generating random bytes")
            }
        }
        
        var saltString = "";
        
        for i in 0..<saltArray.count {
            let utf16 = [
                UInt16((saltArray[i] >> 24) & 0xFF),
                UInt16((saltArray[i] >> 16) & 0xFF),
                UInt16((saltArray[i] >> 8) & 0xFF),
                UInt16((saltArray[i] & 0xFF)) ]
            let word: String = String(utf16CodeUnits: utf16, count: 4)
            
            saltString += word;
        }
        
        /// Encode salt to base64
        guard let rawSaltBytes = saltString.data(using: .utf8) else { preconditionFailure("Failure in encoding the raw string into bytes") }
        guard let encodedSaltBytes = rawSaltBytes.base64EncodedString().data(using: .utf8) else { preconditionFailure("Failure in encoding the generated salt") }
        return Array(encodedSaltBytes)
    }
    
    /// Generates a hashed PIN that's essential to using Authenticate & Sanctum
    ///
    /// - Parameters:
    ///   - saltBytes: Byte array representing a Base64 salted string
    ///   - pin: String representing the user's PIN
    /// - Returns: Hashed PIN of the correct format required for Authenticate & Sanctum
    public static func hashPin(saltBytes: [UInt8], pin: String) -> String? {
        let salt: String = String(bytes: saltBytes, encoding: .utf8)!
        guard let data = (salt + pin).data(using: .utf8) else { return nil }
        
        /// Get Digest
        let dataNS = data as NSData
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(dataNS.bytes, UInt32(dataNS.length), &digest)
        
        let digestWrapper = NSData(bytes: digest, length: Int(CC_SHA256_DIGEST_LENGTH))
        
        /// Encode digest to hex
        var hexDigest = [UInt8](repeating: 0, count: digestWrapper.length)
        digestWrapper.getBytes(&hexDigest, length: digestWrapper.length)
        
        var hexString = ""
        for byte in hexDigest {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        // Encode to base 64 string
        guard let hashPin = hexString.data(using: .utf8) else { return nil }
        return hashPin.base64EncodedString()
    }
}

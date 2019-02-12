import Foundation
import CommonCrypto

public class HaventecCommon {
    static let saltByteSize: Int = 128
    
    private static func generateBytes(length : Int) -> NSData? {
        var bytes = [Int32](repeating: Int32(0), count: length)
        let statusCode = CCRandomGenerateBytes(&bytes, bytes.count)
        
        if statusCode != CCRNGStatus(kCCSuccess) {
            return nil
        } else {
            return NSData(bytes: bytes, length: bytes.count)
        }
    }
    
    public static func generateSalt() -> [UInt8] {
        var saltArray: [Int32] = []
        
        for _ in 0..<saltByteSize {
            var intOut: Int32 = 0;
            
            guard let dataBytes = generateBytes(length: 4) else { preconditionFailure("Failure in generating bytes") }
            dataBytes.getBytes(&intOut, length: MemoryLayout<Int32>.size)
            saltArray.append(intOut);
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
        
        guard let rawSaltBytes = saltString.data(using: .utf8) else { preconditionFailure("Failure in encoding the raw string into bytes") }
        guard let encodedSaltBytes = rawSaltBytes.base64EncodedString().data(using: .utf8) else { preconditionFailure("Failure in encoding the generated salt") }
        return Array(encodedSaltBytes)
    }
    
    public static func hashPin(saltBytes: [UInt8], pin: String) -> String {
        let salt: String = String(bytes: saltBytes, encoding: .utf8)!
        let result: String = salt + pin
        
        if let stringData = result.data(using: .utf8) {
            let hashPin: String = hexStringFromData(input: digest(input: stringData as NSData))
            return hashPin.data(using: .utf8)!.base64EncodedString()
        } else {
            return ""
        }
    }
    
    private static func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private static func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}

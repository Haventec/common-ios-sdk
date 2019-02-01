import Foundation
import CommonCrypto

public class HaventecCommon {
    enum HaventecError: Error {
        case generateSalt
    }
    
    public static func generateSalt(size: Int) throws -> String {
        var saltArray: [Int32] = []
        
        for _ in 0..<size {
            var intOut: Int32 = 0;
            
            if let dataBytes = try? generateBytes(length: 4), let data = dataBytes {
                data.getBytes(&intOut, length: MemoryLayout<Int32>.size)
                saltArray.append(intOut);
            } else {
                throw HaventecError.generateSalt
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
        
        var returnString: String = ""
        if let data = saltString.data(using: .utf8) {
            returnString = data.base64EncodedString()
        }
        
        return returnString
    }
    
    
    public static func hashPin(salt: String, pin: String) -> String {
        var basePin: String = ""
        if let dataPin = salt.data(using: .utf8) {
            basePin = dataPin.base64EncodedString()
        }
        
        let saltString: String = salt + basePin;
        
        let shaString: String = sha512Base64(instring: saltString)
        
        return shaString
    }
    
    private static func generateBytes(length : Int) throws -> NSData? {
        var bytes = [Int32](repeating: Int32(0), count: length)
        let statusCode = CCRandomGenerateBytes(&bytes, bytes.count)
        if statusCode != CCRNGStatus(kCCSuccess) {
            return nil
        }
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    private static func sha512Base64(instring: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = instring.data(using: String.Encoding.utf8) {
            data.withUnsafeBytes({
                _ = CC_SHA512($0, CC_LONG(data.count), &digest)
            })
        }
        
        var shaString = digest.map({ String(format: "%02hhx", $0) }).joined(separator: "")
        
        if let result: Data = shaString.data(using: String.Encoding.utf8) {
           shaString = result.base64EncodedString()
        } else {
            shaString = ""
        }
        
        return shaString
    }
}

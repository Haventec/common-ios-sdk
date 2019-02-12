import Foundation
import CommonCrypto

public class HaventecCommon {
    static let saltByteSize: Int = 128
    
    enum HaventecError: Error {
        case generateSalt(String)
        case hashPin(String)
    }
    
    public static func generateSalt() throws -> [UInt8] {
        var saltArray: [Int32] = []
        
        for _ in 0..<saltByteSize {
            var intOut: Int32 = 0;
            
            if let dataBytes = try? generateBytes(length: 4), let data = dataBytes {
                data.getBytes(&intOut, length: MemoryLayout<Int32>.size)
                saltArray.append(intOut);
            } else {
                throw HaventecError.generateSalt("Error generating random bytes")
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
        
        guard let rawSaltBytes = saltString.data(using: .utf8) else { throw HaventecError.generateSalt("Error encoding the raw string into bytes") }
        
        if let encodedSaltBytes = rawSaltBytes.base64EncodedString().data(using: .utf8) {
            return Array(encodedSaltBytes)
        } else {
            throw HaventecError.generateSalt("Error encoding the generated salt with given charset")
        }
    }
    
    public static func hashPin(saltBytes: [UInt8], pin: String) -> String {
        let salt: String = String(bytes: saltBytes, encoding: .utf8)!
        var basePin: String = ""
        
        if let dataPin = salt.data(using: .utf8) {
            basePin = dataPin.base64EncodedString()
        }

        let saltString: String = salt + basePin;

        let shaString: String = sha512Base64(instring: saltString)

        return shaString
    }
    
//    private func sha512(string string: String) -> [UInt8] {
//        var digest = [UInt8](count: Int(CC_SHA512_DIGEST_LENGTH), repeatedValue: 0)
//        let data = string.dataUsingEncoding(NSUTF8StringEncoding)!
//        CC_SHA512(data.bytes, CC_LONG(data.length), &digest)
//
//        return digest
//    }
    
    private static func generateBytes(length : Int) throws -> NSData? {
        var bytes = [Int32](repeating: Int32(0), count: length)
        let statusCode = CCRandomGenerateBytes(&bytes, bytes.count)
        if statusCode != CCRNGStatus(kCCSuccess) {
            return nil
        }
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    
    
    private static func sha512Base64(instring: String) -> String {
        let digest = NSMutableData(length: Int(CC_SHA512_DIGEST_LENGTH))!
        if let data = instring.data(using: String.Encoding.utf8) {

            let value =  data as NSData
            let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: digest.length)
            CC_SHA512(value.bytes, CC_LONG(data.count), uint8Pointer)

        }
        return digest.base64EncodedString(options: NSData.Base64EncodingOptions([]))
    }
}

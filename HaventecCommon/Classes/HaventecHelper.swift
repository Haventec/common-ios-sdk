import Foundation
import CommonCrypto

open class HaventecHelper {
    
    public init(){}
    
    enum HaventecError: Error {
        case generateSalt
    }
    
    public func generateBytes(length : Int) throws -> NSData? {
        var bytes = [Int32](repeating: Int32(0), count: length)
        let statusCode = CCRandomGenerateBytes(&bytes, bytes.count)
        if statusCode != CCRNGStatus(kCCSuccess) {
            return nil
        }
        return NSData(bytes: bytes, length: bytes.count)
    }
    
    public func generateSalt(size: Int) throws -> String {
        
        var saltArray: [Int32] = [];
        
        for _ in 0..<size {
            var intOut: Int32 = 0;
            let dataBytes = try? generateBytes(length: 4)
            if let data: NSData = dataBytes as? NSData {
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
    
    
    public func doHash(salt: String, pin: String) -> String {
        var basePin: String = ""
        if let dataPin = salt.data(using: .utf8) {
            basePin = dataPin.base64EncodedString()
        }
        
        let saltString: String = salt + basePin;
        
        let shaString: String = sha512Base64(instring: saltString)
        
        return shaString
    }
    
    
    func sha512Base64(instring: String) -> String {
        let digest = NSMutableData(length: Int(CC_SHA512_DIGEST_LENGTH))!
        if let data = instring.data(using: String.Encoding.utf8) {
            
            let value =  data as NSData
            let uint8Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: digest.length)
            CC_SHA512(value.bytes, CC_LONG(data.count), uint8Pointer)
            
        }
        return digest.base64EncodedString(options: NSData.Base64EncodingOptions([]))
    }
    
    func sha512Hex( string: String) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        if let data = string.data(using: String.Encoding.utf8) {
            let value =  data as NSData
            CC_SHA512(value.bytes, CC_LONG(data.count), &digest)
            
        }
        var digestHex = ""
        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    
    func sha512(string: String) -> [UInt8] {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
        let data = string.data(using: String.Encoding.utf8 , allowLossyConversion: true)
        let value =  data! as NSData
        CC_SHA512(value.bytes, CC_LONG(value.length), &digest)
        
        return digest
    }
    
    
    //    public func sha512Hex(instring: String) -> String {
    //        var digest = [UInt8](repeating: 0, count: Int(CC_SHA512_DIGEST_LENGTH))
    //        if let data = instring.data(using: String.Encoding.utf8) {
    //            _ = data.withUnsafeBytes {dataBytes in
    //                CC_SHA512(dataBytes, CC_LONG(data.count), &digest)
    //            }
    //        }
    //
    ////        let characters = digest.map { Character(UnicodeScalar($0)) }
    ////        return String(Array(characters))
    //
    ////        if let shaString: String = String(bytes: digest, encoding: .utf8) {
    ////            return shaString
    ////        } else {
    ////            return ""
    ////        }
    //
    ////        var digestHex = ""
    ////        for index in 0..<Int(CC_SHA512_DIGEST_LENGTH) {
    ////            digestHex += String(format: "%02x", digest[index])
    ////        }
    ////
    ////        return digestHex
    //    }
}

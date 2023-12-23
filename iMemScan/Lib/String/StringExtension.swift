//
//  StringExtension.swift
//  StringExtension
//
//  Created by yiming on 2021/8/22.
//

import UIKit
import Foundation
import CommonCrypto

extension String {
    
    // MARK: - 字符串截取
    
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
    // MARK: - base64 函数
    
    // base64 编码
    func toBase64() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // base64 解码
    func fromBase64() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    // MARK: - 散列函数
    
    var s2: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    // MARK: - HMAC 散列函数
    
    func h2(_ key: String) -> String {
        let keyData = key.cString(using: String.Encoding.utf8)
        let strData = cString(using: .utf8)
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), keyData, strlen(keyData!), strData, strlen(strData!), &buffer)
        
        return buffer.reduce("") { $0 + String(format:"%02x", $1) }
    }
}

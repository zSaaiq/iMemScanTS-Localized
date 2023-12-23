//
//  StringMD5.swift
//  iMemScan
//
//  Created by 李良林 on 2020/12/9.
//  Copyright © 2020 李良林. All rights reserved.
//

import UIKit
import CommonCrypto

extension String {
    
    // MARK: - 32位 小写
    
    func md5ForLower32Bate() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        
        for i in 0 ..< Int(CC_MD5_DIGEST_LENGTH) {
            hash.appendFormat("%02x", result[i])
        }
        
        return String(format: hash as String)
    }
}

class Filezmd5: NSObject {

    static func fileMD5(path: String) -> String? {
        
        let handle = FileHandle(forReadingAtPath: path)
        
        if handle == nil {
            return nil
        }

        let ctx = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: MemoryLayout<CC_MD5_CTX>.size)
        
        CC_MD5_Init(ctx)
        
        var done = false
        
        while !done {
            let fileData = handle?.readData(ofLength: 256)
            fileData?.withUnsafeBytes {(bytes: UnsafePointer<CChar>)->Void in
                CC_MD5_Update(ctx, bytes, CC_LONG(fileData!.count))
            }
            
            if fileData?.count == 0 {
                done = true
            }
        }
        
        //unsigned char digest[CC_MD5_DIGEST_LENGTH];
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let digest = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        CC_MD5_Final(digest, ctx);
        
        var hash = ""
        for i in 0..<digestLen {
            hash +=  String(format: "%02x", (digest[i]))
        }
        
        return hash;

    }
}


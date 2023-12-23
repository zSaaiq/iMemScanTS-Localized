//
//  UIDevice+Helper.swift
//  iMemScan
//
//  Created by 李良林 on 2020/12/5.
//  Copyright © 2020 李良林. All rights reserved.
//

import UIKit

extension UIDevice {

    class func deviceIsPhone() -> Bool {
        // 判断 iPhone/iPad
        var _isIdiomPhone = true // 默认是iPhone
        let currentDevice = UIDevice.current

        if currentDevice.userInterfaceIdiom == .phone {
            // iPhone
            _isIdiomPhone = true
        } else if currentDevice.userInterfaceIdiom == .pad {
            // iPad
            _isIdiomPhone = false
        }

        return _isIdiomPhone
    }
    
//    class func rootRemoval() -> String? {
//        
//        /*
//         UniqueDeviceID
//         WifiAddress
//         BluetoothAddress
//         SerialNumber
//         */
//        
//        let gestalt = dlopen(VMImage.r1, RTLD_GLOBAL | RTLD_LAZY)
//        typealias MGCopyAnswerFunc = @convention(c) (CFString) -> CFString
//        let MGCopyAnswer = unsafeBitCast(dlsym(gestalt, VMImage.r2), to: MGCopyAnswerFunc.self)
//        
//        return MGCopyAnswer(VMImage.r3 as CFString) as String
//    }
    
    
}

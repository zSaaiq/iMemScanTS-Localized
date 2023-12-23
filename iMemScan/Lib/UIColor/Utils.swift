//
//  Utils.swift
//  ControlBoardSwift
//
//  Created by 李良林 on 2020/11/21.
//  Copyright © 2020 李良林. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(rgb: UInt) {
       self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: CGFloat(1.0))
    }
    
    static func dynamicColor(_ lightColor: UIColor, darkColor: UIColor? = UIColor.white)  -> UIColor {
        return UIColor.init { (traitCollection) -> UIColor in
            if traitCollection.userInterfaceStyle == .light {
                return lightColor
            }else{
                return darkColor!
            }
        }
    }
}



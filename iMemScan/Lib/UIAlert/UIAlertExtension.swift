//
//  UIAlertExtension.swift
//  iMemScan
//
//  Created by 李良林 on 2020/12/5.
//  Copyright © 2020 李良林. All rights reserved.
//

import UIKit

let windows = UIApplication.shared.windows[0].rootViewController

extension UIAlertController {

    // MARK: --- 长按保存弹窗
    
    static func showAlert_Longpress(_ title: String?, message: String?, holder: String?, buttonTitle btnTitle: String?, handler: @escaping (_ text: String?) -> Void) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = holder
        })
        
        alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { action in
            let textField = alertCtrl.textFields?[0]
            handler(textField?.text!)
        }))

        windows?.present(alertCtrl, animated: true)
    }
    
    static func showAlert_holder(_ title: String?, message: String?, holder: String?, buttonTitle btnTitle: String?, handler: @escaping (_ text: String?) -> Void) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = holder
            textField.text = holder
        })
        
        alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { action in
            let textField = alertCtrl.textFields?[0]
            if textField?.text == "" {
                return
            }

            handler(textField?.text!)
        }))

        windows?.present(alertCtrl, animated: true)
    }
    
    static func showAlert(_ title: String?, message: String?, holder: String?, buttonTitle btnTitle: String?, handler: @escaping (_ text: String?) -> Void) {
        
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = holder
        })
        
        alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { action in
            let textField = alertCtrl.textFields?[0]
            if textField?.text == "" {
                return
            }

            handler(textField?.text!)
        }))

        windows?.present(alertCtrl, animated: true)
    }
    
    static func showAlert2(_ title: String?, message: String?) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        UIApplication.shared.windows[0].rootViewController?.present(alertCtrl, animated: true)
    }
    
    static func showAlert3(_ title: String?, message: String?) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        windows?.present(alertCtrl, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            windows?.dismiss(animated: false, completion: nil)
        }
    }
    
    static func showAlert4(_ title: String?, message: String?, btnTitle: String?) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertCtrl.addAction(UIAlertAction(title: btnTitle, style: .default, handler: { action in
            
        }))
        
        windows?.present(alertCtrl, animated: true)
    }
    
    static func showAlert5(_ title: String?, message: String?, buttonTitle btnTitle: String?, isdefault: Bool, handler: @escaping () -> Void) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
        
        let style: UIAlertAction.Style = isdefault ? .default : .destructive
        
        alertCtrl.addAction(UIAlertAction(title: btnTitle, style: style, handler: { action in
            handler()
        }))
        
        windows?.present(alertCtrl, animated: true)
    }
}

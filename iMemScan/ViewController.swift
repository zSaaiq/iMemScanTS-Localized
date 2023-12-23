//
//  ViewController.swift
//  iMemScan
//
//  Created by yiming on 2021/8/4.
//

import UIKit
import Foundation

@discardableResult func eng(_ str: String) -> String {
    return NSLocalizedString(str, comment: "")
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UIApplication.shared.delegate?.window?!.rootViewController = VMTabBarCtrl()
    }
    
}



//
//  PokerCarda.swift
//  iMemScan
//
//  Created by 李良林 on 2021/1/5.
//  Copyright © 2021 李良林. All rights reserved.
//

import UIKit

class PokerCarda: NSObject {
    
    public func showInput(title: String, detail: String? = nil) -> PokerInputView {
        return PokerAlertPresenter().showInput(title: title, detail: detail)
    }
}

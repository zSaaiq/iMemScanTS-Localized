//
//  VMHelpCtrl.swift
//  YMTool
//
//  Created by yiming on 2021/7/7.
//

import UIKit

class AppNoticeCtrl: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("Terms of Service Notification", comment: "")
        //setupViews()
    }
    
//    func setupViews() {
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationItem.largeTitleDisplayMode = .never
//        view.addSubview(textView)
//
//        let udid = UIDevice.rootRemoval()
//
//        VMWLTool.query(udid!) { [self] (result) in
//            //
//            let dict = result
//            let notice = dict[Key._14.rawValue].stringValue
//
//            let text = """
//            \(notice)
//            """
//            textView.text = text
//        }
//    }

    // MARK: - 懒加载
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.frame = self.view.bounds
        textView.text = NSLocalizedString("Loading...", comment: "")
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textAlignment = .left
        textView.showsVerticalScrollIndicator = false
        textView.isEditable = false
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        return textView
    }()
}

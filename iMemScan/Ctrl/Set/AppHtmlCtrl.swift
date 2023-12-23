//
//  AppHtmlCtrl.swift
//  YMTool
//
//  Created by yiming on 2021/7/8.
//

import UIKit
import WebKit

class AppHtmlCtrl: UIViewController, WKUIDelegate, WKNavigationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("Release Notes", comment: "")
        setupViews()
    }
    
    func setupViews() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.largeTitleDisplayMode = .never
        
        view.addSubview(webView)
    }
    
    @objc func buttonAction(_ button: UIButton?) {
        if button?.tag == 0 {
            dismiss(animated: true)
        }
    }
    
    // MARK: - 懒加载
    
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.frame = self.view.bounds
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        let backForwardList = webView.backForwardList
        
        let bundlePath = Bundle.main.bundlePath
        
        let path = "file://\(bundlePath)/LocalFiles/updaterecord.html"
        let request = URLRequest(url: URL(string: path)!)
        
        // 加载本地html文件
        webView.load(request)
        // 页面后退
        webView.goBack()
        // 页面前进
        webView.goForward()
        // 刷新当前页面
        webView.reload()
        
        return webView
    }()
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

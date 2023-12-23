//
//  AboutCtrl.swift
//  YMTool
//
//  Created by HaoCold on 2021/7/7.
//

import UIKit

class AboutCtrl: UIViewController {
    
    let debPath = "/var/mobile/Documents/iMemScan(Script)/iMemScan.deb"
    
    
    public static let shared = AboutCtrl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = nil
        self.view.backgroundColor = .secondarySystemBackground
        self.setupViews()
    }
    
    func setupViews() {
        self.view.addSubview(self.icon)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.bottomLabel)
        self.view.addSubview(self.bottomLabel2)
        icon.top = 150
        icon.centerX = self.view.centerX
        
        titleLabel.top = icon.bottom + 20
        
        subTitleLabel.top = titleLabel.bottom + 10
        
        tableView.top = subTitleLabel.bottom + 20
        
        bottomLabel.bottom = self.view.height - 40
        bottomLabel2.bottom = self.view.height - 20
    }
    
    // MARK: --- lazy
    
    lazy var icon: UIImageView = {
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        icon.image = UIImage(named: "AppIcon60x60@2x")
        //icon.backgroundColor = .gray
        icon.clipsToBounds = true
        icon.layer.cornerRadius = 15
        return icon
    }()
    
    lazy var titleLabel: UILabel = {
        let executableFile = Bundle.main.infoDictionary![kCFBundleExecutableKey as String] as? String
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 20))
        label.text = executableFile
        label.font = .boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    lazy var subTitleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 16))
        let app_Version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String
        label.text = "Version \(app_Version ?? "")"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 15, y: 0, width: self.view.width-30, height: 4*50), style: .plain)
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 20))
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.text = "Copyright © 2022 无名. All Rights Reserved."
        return label
    }()
    lazy var bottomLabel2: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 20))
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.text = "English and German Localisation by zSaaiq @0x1585D65F0"
        return label
    }()
}

extension AboutCtrl: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ID = "reuse"
        var cell = tableView.dequeueReusableCell(withIdentifier: ID)
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: ID)
            cell?.accessoryType = .disclosureIndicator
        }
        
        switch indexPath.row {
        case 0:
            cell?.textLabel?.text = NSLocalizedString("Feature Introduction", comment: "")
            cell?.imageView?.image = UIImage(systemName: "paperclip")
            cell?.backgroundColor = .secondarySystemBackground
        case 1:
            cell?.textLabel?.text = NSLocalizedString("Uninstall App", comment: "")
            cell?.imageView?.image = UIImage(systemName: "clear")
            cell?.backgroundColor = .secondarySystemBackground
        case 2:
            cell?.textLabel?.text = NSLocalizedString("Download Update", comment: "")
            cell?.imageView?.image = UIImage(systemName: "icloud.and.arrow.down")
            cell?.backgroundColor = .secondarySystemBackground
            
            let filePath = Bundle.main.path(forResource: "iMemScan", ofType: nil)
            
//            if ViewController.test1 == Filezmd5.fileMD5(path: fliePath!) {
//                cell?.detailTextLabel?.text = "暂无更新"
//            } else {
//                cell?.detailTextLabel?.text = "有新版本"
//            }
//        case 3:
//            cell?.textLabel?.text = "授权过期"
//            cell?.detailTextLabel?.text = ViewController.test
//            cell?.imageView?.image = UIImage(systemName: "clock.arrow.circlepath")
//            cell?.selectionStyle = .none
//            cell?.backgroundColor = .secondarySystemBackground
            
        default:
            cell?.textLabel?.text = nil
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0: apphtml()
        case 1: remove_deb(tableView,index: indexPath)
        case 2: detect()
        default:
            break
        }
    }
    
    func detect() {
        let filePath = Bundle.main.path(forResource: "iMemScan", ofType: nil)
        
//        if ViewController.test1 == Filezmd5.fileMD5(path: fliePath!) {
//
//            let drop = Drop(
//                title: "暂无更新",
//                subtitle: "您当前版本无需更新",
//                icon: UIImage(systemName: "checkmark.icloud.fill"),
//                position: .top,
//                duration: .seconds(5)
//            )
//            Drops.show(drop)
//
//        } else {
//            let vc = DownloadCtrl()
//            vc.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func apphtml() {
        let vc = AppHtmlCtrl()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func remove_deb(_ tableView: UITableView?, index indexPath: IndexPath?) {
        
        let alertCtrl = UIAlertController(title: NSLocalizedString("Uninstall command", comment: ""), message: NSLocalizedString("Are you sure you want to uninstall this app?", comment: ""), preferredStyle: .actionSheet)
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Confirm to uninstall", comment: ""), style: .destructive, handler: { action in
            runCmd(path: "/usr/bin/dpkg", args: ["--remove", "com.qiyue"])
            runCmd(path: "/usr/bin/uicache", args: ["-p", "/Applications/Tianyamodifier.app"])
            runCmd(path: "/usr/bin/killall", args: ["-9", "SpringBoard"])
        }))
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        if UIDevice.deviceIsPhone() {
            // iPhone
            present(alertCtrl, animated: true)
        } else {
            // iPad
            let rectInTableview = tableView!.rectForRow(at: indexPath!)
            let rectInSuperview = tableView!.convert(rectInTableview, to: tableView?.superview)
            let popover = alertCtrl.popoverPresentationController
            if (popover != nil) {
                popover?.sourceView = tableView?.superview
                popover?.sourceRect = rectInSuperview
                popover?.permittedArrowDirections  = .up
            }
            
            present(alertCtrl, animated: true)
        }
    }
}

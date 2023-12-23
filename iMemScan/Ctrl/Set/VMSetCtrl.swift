//
//  VMSetCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit
import MessageUI

class VMSetCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    var setTool: SetModel = SetModel.fetch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        setupViews()
    }
    
    // MARK: - 视图
    
    func setupViews() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        
        view.addSubview(tableView)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 2
        } else if section == 3 {
            return 3
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "resueID")
        }
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                cell?.textLabel?.text = NSLocalizedString("Search Lower Limit", comment: "")
                cell?.detailTextLabel?.text = VMTool.share().addrRange()
                cell?.imageView?.image = UIImage(systemName: "arrow.down", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            } else {
                cell?.textLabel?.text = NSLocalizedString("Search Upper Limit", comment: "")
                cell?.detailTextLabel?.text = VMTool.share().addrRangeUpp()
                cell?.imageView?.image = UIImage(systemName: "arrow.up", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            return cell!
        case 1:
            if indexPath.row == 0 {
                cell?.textLabel?.text = NSLocalizedString("Nearby Range", comment: "")
                cell?.detailTextLabel?.text = VMTool.share().rangeStringValue()
                cell?.imageView?.image = UIImage(systemName: "capsule", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            } else {
                cell?.textLabel?.text = NSLocalizedString("Limit Count", comment: "")
                cell?.detailTextLabel?.text = "\(NSNumber(value: VMTool.share().limitCount()).stringValue)"
                cell?.imageView?.image = UIImage(systemName: "rectangle.slash", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            return cell!
        case 2:
            if indexPath.row == 0 {
                cell?.textLabel?.text = NSLocalizedString("Loop Script", comment: "")
                cell?.detailTextLabel?.text = String(format: NSLocalizedString("%ld Seconds" , comment: ""), VMTool.share().duration())
                cell?.imageView?.image = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }else {
                cell?.textLabel?.text = NSLocalizedString("Data Lock", comment: "")
                cell?.detailTextLabel?.text = String(format: NSLocalizedString("%ld Seconds" , comment: ""), VMTool.share().duration1())
                cell?.imageView?.image = UIImage(systemName: "alarm", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            return cell!
        case 3:
            if indexPath.row == 0 {
                cell?.textLabel?.text = NSLocalizedString("Night Mode", comment: "")
                cell?.detailTextLabel?.text = ""
                cell!.accessoryType = .disclosureIndicator
                cell?.imageView?.image = UIImage(systemName: "powersleep", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            else if indexPath.row == 1 {
                cell?.textLabel?.text = NSLocalizedString("Usage Agreement", comment: "")
                cell?.detailTextLabel?.text = ""
                cell!.accessoryType = .disclosureIndicator
                cell?.imageView?.image = UIImage(systemName: "book", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            else {
                cell?.textLabel?.text = NSLocalizedString("About App", comment: "")
                cell?.detailTextLabel?.text = ""
                cell!.accessoryType = .disclosureIndicator
                cell?.imageView?.image = UIImage(systemName: "tornado", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            return cell!
            
        case 4:
            if indexPath.row == 0 {
                cell?.textLabel?.text = "QQ:350722326"
                cell?.detailTextLabel?.text = ""
                cell!.accessoryType = .disclosureIndicator
                cell?.imageView?.image = UIImage(systemName: "message", withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
            }
            return cell!
        default:
            break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                // 搜索下限
                searchRangeAction(tableView, index: indexPath)
            } else {
                // 搜索上限
                searchRangeUppAction(tableView, index: indexPath)
            }
        case 1:
            if indexPath.row == 0 {
                // 邻近范围
                nearRangeAction(tableView, index: indexPath)
            } else {
                // 限制数量
                resultAction(tableView, index: indexPath)
            }
        case 2:
            if indexPath.row == 0 {
                // 循环脚本
                lockingAction(tableView, index: indexPath)
            }else {
                lockingAction1(tableView, index: indexPath)
            }
        case 3:
            if indexPath.row == 0 {
                showAppearance()
            }
            else if indexPath.row == 1 {
                // 快捷帮助
                helpAction()
            }
            if indexPath.row == 2 {
                // 关于应用
                let vc = AboutCtrl()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case 4:
            if indexPath.row == 0 {
                
                let messageVC = MFMessageComposeViewController()
                messageVC.messageComposeDelegate = self
                messageVC.recipients = ["350722326@qq.com"]
                messageVC.subject = "iMemScan"
                
                present(messageVC, animated: true, completion: nil)
            }

        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: "header")
        }
        
        if section == 0 {
            view?.textLabel?.text = NSLocalizedString("Search range", comment: "")
        }
        
        if section == 1 {
            view?.textLabel?.text = NSLocalizedString("Nearby", comment: "")
        }
        
        if section == 2 {
            view?.textLabel?.text = NSLocalizedString("Loop Script", comment: "")
        }
        
        if section == 3 {
            view?.textLabel?.text = NSLocalizedString("Instructions for use", comment: "")
            
        }
        
        if section == 4 {
            view?.textLabel?.text = NSLocalizedString("Contact information", comment: "")
            
        }
        
        return view
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let titles = ["", NSLocalizedString("Search result limit", comment: ""), NSLocalizedString("Cycle modification", comment: ""), "", "", " "]
        
        if section == 0 {
            return titles[0]
        } else if section == 1 {
            return titles[1]
        } else if section == 2 {
            return titles[2]
        } else {
            return titles[3]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else if section == 1 {
            return 30
        } else if section == 2 {
            return 30
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else if section == 1 {
            return 30
        } else if section == 2 {
            return 30
        } else {
            return 25
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
        switch result {
        case MessageComposeResult.sent:
            //print("发送成功")
            let drop = Drop(
                title: "Hey",
                subtitle: NSLocalizedString("Send message successfully", comment: ""),
                icon: UIImage(systemName: "message.circle"),
                position: .top,
                duration: .seconds(3)
            )
            Drops.show(drop)
        case MessageComposeResult.failed:
            //print("发送信息失败")
            let drop = Drop(
                title: "Hey",
                subtitle: NSLocalizedString("Failed to send message", comment: ""),
                icon: UIImage(systemName: "message.circle"),
                position: .top,
                duration: .seconds(3)
            )
            Drops.show(drop)
        case MessageComposeResult.cancelled:
            //print("发送取消")
            let drop = Drop(
                title: "Hey",
                subtitle: NSLocalizedString("Message not send", comment: ""),
                icon: UIImage(systemName: "message.circle"),
                position: .top,
                duration: .seconds(3)
            )
            Drops.show(drop)
        default:
            break
        }
    }
        
    // MARK: - 懒加载
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 42
        tableView.sectionHeaderHeight = 30
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = true
        tableView.isScrollEnabled = true
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.separatorStyle = .none
        
        // 增加顶部距离
        tableView.tableHeaderView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
            view.backgroundColor = UIColor.clear
            return view
        }()
        
        return tableView
    }()
    
    func showAppearance() {
        showAppearanceOptions()
            .config(light: {
                print("light selected")
            }, dark: {
                print("dark selected")
            }) {
                print("auto selected")
        }
        .setTitles(
            title: NSLocalizedString("Select Theme", comment: ""),
            light: NSLocalizedString("Light", comment: ""),
            dark: NSLocalizedString("Dark", comment: ""),
            auto: NSLocalizedString("Auto", comment: "")
        )
    }
    
    // MARK: - 邻近范围
    
    func nearRangeAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Nearby Range", comment: ""), message: "", preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set the nearby range", comment: "")
            textField.text = VMTool.share().rangeStringValue()
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in

            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }
            
            setTool.range = (textField?.text)!
            setTool.save()
            
            VMTool.share().setRange((textField?.text)!)

            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = "\(VMTool.share().rangeStringValue())"
        }))

        present(alertCtrl, animated: true)
    }
    
    // MARK: - 下限范围修改
    func searchRangeAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Lower Limit Range", comment: ""), message: "", preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set the lower limit range", comment: "")
            textField.text = VMTool.share().addrRange()
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }
            
            setTool.addrRangeStart = (textField?.text)!
            setTool.save()

            //
            VMTool.share().setAddrRange((textField?.text)!)

            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = "\(VMTool.share().addrRange())"
        }))

        present(alertCtrl, animated: true)
    }

    
    // MARK: - 上限范围修改
    func searchRangeUppAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Upper Limit Range", comment: ""), message: "", preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set the upper limit range", comment: "")
            textField.text = VMTool.share().addrRangeUpp()
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }
            
            setTool.addrRangeEnd = (textField?.text)!
            setTool.save()

            //
            VMTool.share().setAddrRangeUpp((textField?.text)!)

            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = "\(VMTool.share().addrRangeUpp())"
        }))

        present(alertCtrl, animated: true)
    }
    
    // MARK: - 结果限制修改
    func resultAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Result Limit", comment: ""), message: NSLocalizedString("Please set the result count", comment: ""), preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set result limit", comment: "")
            textField.text = NSNumber(value: VMTool.share().limitCount()).stringValue
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }
            
            setTool.LimitCount = (textField?.text)!
            setTool.save()

            //
            VMTool.share().setLimitCount((textField?.text)!)

            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = "\(NSNumber(value: VMTool.share().limitCount()).stringValue)"
        }))

        present(alertCtrl, animated: true)
    }
    
    // MARK: --- 锁定修改
    func lockingAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Loop Script", comment: ""), message: NSLocalizedString("Please do not set too small time, otherwise it may consume all the phone's running memory and crash!", comment: ""), preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set time: seconds", comment: "")
            textField.text = String(format: "%ld", VMTool.share().duration())
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }

            setTool.duration = (textField?.text)!
            setTool.save()
            
            //
            VMTool.share().setDuration((textField?.text)!)

            //
            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = String(format: "%ld %@", VMTool.share().duration(), NSLocalizedString("seconds", comment: ""))
        }))

        present(alertCtrl, animated: true)
    }
    
    func lockingAction1(_ tableView: UITableView?, index indexPath: IndexPath?) {
        let alertCtrl = UIAlertController(title: NSLocalizedString("Data Lock", comment: ""), message: NSLocalizedString("Please do not set too small time, otherwise it may consume all the phone's running memory and crash!", comment: ""), preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = NSLocalizedString("Please set time: seconds", comment: "")
            textField.text = String(format: "%ld", VMTool.share().duration1())
            textField.clearButtonMode = .whileEditing
        })
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify", comment: ""), style: .default, handler: { [self] action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }
            
            setTool.duration1 = (textField?.text)!
            setTool.save()

            //
            VMTool.share().setDuration1((textField?.text)!)

            //
            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.detailTextLabel?.text = String(format: "%ld %@", VMTool.share().duration1(), NSLocalizedString("seconds", comment: ""))
        }))

        present(alertCtrl, animated: true)
    }
    
    // MARK: - 使用说明
    func helpAction() {
        navigationController?.pushViewController(AppNoticeCtrl(), animated: true)
    }
    
}

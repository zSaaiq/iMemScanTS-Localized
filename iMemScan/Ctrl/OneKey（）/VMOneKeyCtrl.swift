//
//  VMOneKeyCtrl.swift
//  iMemScan
//
//  Created by 李良林 on 2020/12/5.
//  Copyright © 2020 李良林. All rights reserved.
//

import UIKit

class VMOneKeyCtrl: UITableViewController {
    
    var dataArray: [Any] = []
    var indexs: [Any] = []
    var indexPath: IndexPath?
    var isSelect:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = "执行脚本"
        setupViews()
    }
    
    // MARK: - 视图
    
    func setupViews() {
        
        dataArray = []
        indexs = []
        VMOneKeyTool.setup()
        dataArray.append(contentsOf: VMOneKeyTool.allRecords())
        
        NotificationCenter.default.addObserver(self, selector: #selector(nextAction), name: NSNotification.Name("kVMMdFinish"), object: nil)
        
//        let paixu = UIBarButtonItem(title: "排序", style: .plain, target: self, action: #selector(sortAction))
//        paixu.tintColor = .red
//        
//        navigationController?.navigationBar.shadowImage = UIImage()
//        navigationItem.rightBarButtonItems = [
//            UIBarButtonItem(title: "排序", style: .plain, target: self, action: #selector(sortAction)),
//            UIBarButtonItem(title: "添加", style: .plain, target: self, action: #selector(addAction)),
//            paixu
//        ]
        
        let titles = ["排序", "添加"]
        var items: [AnyHashable]? = []
        for i in 0..<titles.count {
            let button = UIButton(type: .system)
            button.frame = .init(x: 0, y: 0, width: 50, height: 25)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(titles[i], for: .normal)
            button.setTitle(titles[i], for: .highlighted)
            button.tag = i
            button.layer.cornerRadius = 12.5
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

            let item = UIBarButtonItem(customView: button)
            items?.append(item)
        }
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItems = items as? [UIBarButtonItem]
        
        tableView.rowHeight = 44
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))
    }
    
    // MARK: - 排序
    
    @objc func buttonAction(_ button: UIBarButtonItem?) {
        if button?.tag == 0 {
            sortAction()
        }else if button?.tag == 1 {
            addAction()
        }
    }
    
    @objc func sortAction() {
        let flag = tableView.isEditing
        tableView.setEditing(!flag, animated: true)
        
        if flag {
            VMOneKeyTool.save()
        }
        
        self.tableView.reloadData()
    }
    
    @objc func nextAction() {
        if indexs.count > 0 {
            let indexPath = indexs[0]
            let model = dataArray[(indexPath as AnyObject).row ?? 0]
            
            VMTool.share().reset()
            VMTool.share().oneKeySetup((model as AnyObject).steps as! [Any])
            
            indexs.remove(at: 0)
        } else {
            VMTool.share().modifying = false
        }
    }
    
    // MARK: - 添加
    @objc func addAction() {
        UIAlertController.showAlert("添加脚本", message: nil, holder: "名称", buttonTitle: "确定", handler: { [self] text in
            let model = VMOneKeyModel()
            model.name = text!
            
            self.dataArray.append(model)
            self.tableView.reloadData()
            
            VMOneKeyTool.saveRecord(model)
            VMOneKeyTool.save()
        })
    }
    
    // MARK: - 长按重复名
    @objc func longPressAction(_ gesture: UIGestureRecognizer?) {
        let indexPath = tableView.indexPathForRow(at: gesture?.location(in: gesture?.view) ?? CGPoint.zero)
        if indexPath == nil {
            return
        }
        
        let model = dataArray[indexPath!.row] as! VMOneKeyModel
        
        let title = "修改(\(model.name))名称"
        UIAlertController.VMOneKeyCtrlshowAlert(title, message: "注意后面两个字带有[定时]两个字\n代表需要循环执行脚本", holder: model.name, buttonTitle: "修改", handler: { [self] text in
            model.name = text!
            
            self.tableView.reloadData()
            VMOneKeyTool.save()
        })
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID") as? VMOneKeyCell
        if cell == nil {
            cell = VMOneKeyCell(style: .default, reuseIdentifier: "resueID")
        }
        cell?.indexPath = indexPath
        
        let model = dataArray[indexPath.row] as! VMOneKeyModel
        cell?.setModel(model)
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView.isEditing {
            return
        }
        
        let ctrl = VMOneKeyAddCtrl()
        ctrl.model = (dataArray[indexPath.row] as! VMOneKeyModel)
        navigationController?.pushViewController(ctrl, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if indexPath.row == 0 {
            print("=== 0")
        } else if indexPath.row == 1 {
            print("=== 1")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        dataArray.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        VMOneKeyTool.exchange(sourceIndexPath.row, index: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = dataArray[indexPath.row] as!VMOneKeyModel
            
            dataArray.remove(at: indexPath.row)
            tableView.reloadData()
            
            VMOneKeyTool.deleteRecord(model)
            VMOneKeyTool.save()
        }
    }
    
    override func jh_router(withSelector selector: String?, sender: Any?, info: [AnyHashable : Any]?) {
        let kOneKeySwitchEvent = "kOneKeySwitchEvent"
        if selector == kOneKeySwitchEvent {
            let indexPath = info?["indexPath"] as? IndexPath
            let model = dataArray[indexPath?.row ?? 0]
            
            if VMTool.share().modifying {
                if let indexPath = indexPath {
                    indexs.append(indexPath)
                }
            } else {
                VMTool.share().reset()
                VMTool.share().oneKeySetup((model as AnyObject).steps as! [Any])
            }
        }
    }
    
    // MARK: - 懒加载
    
    //    lazy var tableView: UITableView = {
    //        let tableView = UITableView(frame: view.bounds, style: .plain)
    //        tableView.delegate = self
    //        tableView.dataSource = self
    //        tableView.rowHeight = 42
    //        tableView.tableFooterView = UIView()
    //        tableView.showsVerticalScrollIndicator = false
    //        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    //
    //        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))
    //
    //        return tableView
    //    }()
    
}

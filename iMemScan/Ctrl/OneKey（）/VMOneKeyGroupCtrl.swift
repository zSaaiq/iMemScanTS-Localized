//
//  VMOneKeyGroupCtrl.swift
//  iMemScan
//
//  Created by HaoCold on 2021/8/20.
//

import UIKit

class VMOneKeyGroupCtrl: UITableViewController {

    var dataArray: [VMOneKeyGroupModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "脚本分组"
        setupViews()
    }

    // MARK: - 视图
    
    func setupViews() {
        
        dataArray = []
        VMOneKeyTool.setup()
        let arr = VMOneKeyTool.allRecords(.group)
        for model in arr {
            dataArray.append(model as! VMOneKeyGroupModel)
        }
                
        let titles = ["添加"]
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
    }
    
    // MARK: - 排序
    
    @objc func buttonAction(_ button: UIBarButtonItem?) {
        if button?.tag == 0 {
            addAction()
        }
    }
    
    // MARK: - 添加
    @objc func addAction() {
        UIAlertController.showAlert("添加组", message: nil, holder: "名称", buttonTitle: "确定", handler: { [self] text in
            let model = VMOneKeyGroupModel()
            model.name = text!
            
            self.dataArray.append(model)
            self.tableView.reloadData()
            
            VMOneKeyTool.saveGroup(model)
            VMOneKeyTool.save(.group)
        })
    }
}

extension VMOneKeyGroupCtrl {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "resueID")
        }
        
        let model = dataArray[indexPath.row]
        cell?.textLabel?.text = model.name
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataArray[indexPath.row]
        
        let ctrl = VMOneKeyCtrl()
        ctrl.gid = model.gid
        
        navigationController?.pushViewController(ctrl, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let alertCtrl = UIAlertController(title: "提示", message: "确定删除该组?", preferredStyle: .alert)
            alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alertCtrl.addAction(UIAlertAction(title: "删除", style: .destructive, handler: { action in
                let model = self.dataArray[indexPath.row]
                
                self.dataArray.remove(at: indexPath.row)
                tableView.reloadData()
                
                VMOneKeyTool.deleteGroup(model)
                VMOneKeyTool.saveAll()
            }))
            self.present(alertCtrl, animated: true, completion: nil)
        }
    }
}

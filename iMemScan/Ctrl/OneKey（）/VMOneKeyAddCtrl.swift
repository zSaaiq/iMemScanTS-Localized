//
//  VMOneKeyAddCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/8/2.
//

import UIKit

class VMOneKeyAddCtrl: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var model: VMOneKeyModel?
    var dataArray: [Any] = []
    var alertView: JHUIAlertView?
    var typeKeyValues:[AnyHashable : Any]? // 类型
    var addModel: VMOneKeySubModel?
    
    var offsetY: CGFloat = 0.0
    var searchType:NSInteger = 0
    var modifyType:NSInteger = 0
    
    let kTitle1 = "搜索"
    let kTitle2 = "邻近范围"
    let kTitle3 = "邻近搜索"
    let kTitle4 = "修改"
    let kTitle5 = "清除结果"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = model?.name

        for model in model!.steps {
            dataArray.append(model)
        }
        
        setupViews()
    }
    
    // MARK: - 视图
    
    func setupViews() {
        
        let add = UIBarButtonItem.init(image: UIImage(systemName: "square.and.pencil"), style: .done, target: self, action: #selector(addAction(_:)))
        
        add.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.rightBarButtonItems = [
            add
        ]

        view.addSubview(tableView)
    }
    
    // MARK: - 事件
    
    @objc
    func saveAction() {
        let alertCtrl = UIAlertController(title: "提示", message: "保存成功！", preferredStyle: .alert)
        alertCtrl.addAction(UIAlertAction(title: "确认返回", style: .default, handler: { [self] action in
            VMOneKeyTool.save()
            navigationController?.popViewController(animated: true)
        }))

        present(alertCtrl, animated: true)
    }
    
    @objc func addAction(_ btn: UIBarButtonItem?) {
        
        let alertCtrl = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let model = VMOneKeySubModel()
        
        alertCtrl.addAction(UIAlertAction(title: kTitle1, style: .default, handler: { [self] action in
            searchType = 0
            
            model.type = .numberSearch
            model.typeName = kTitle1

            addModel = model
            showAlert(kTitle1, holder: "", btnTitle: "搜索")
        }))
        
        alertCtrl.addAction(UIAlertAction(title: kTitle2, style: .default, handler: { [self] action in
            
            model.type = .nearRange
            model.typeName = kTitle2
            
            let alertCtrl = UIAlertController(title: kTitle2, message: "", preferredStyle: .alert)

            alertCtrl.addTextField(configurationHandler: { textField in
                textField.placeholder = "请设置邻近范围"
                textField.text = VMTool.share().rangeStringValue()
            })
            
            alertCtrl.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            alertCtrl.addAction(UIAlertAction(title: "修改", style: .default, handler: { [self] action in
                let textField = alertCtrl.textFields?[0]
                if textField!.text!.count == 0 {
                    return
                }

                model.key = ""
                model.value = (textField?.text)!

                dataArray.append(model)
                tableView.reloadData()

                self.model!.steps.add(model)
            }))

            present(alertCtrl, animated: true)
        }))
        
        alertCtrl.addAction(UIAlertAction(title: kTitle3, style: .default, handler: { [self] action in
            searchType = 0
            
            model.type = .nearSearch
            model.typeName = self.kTitle3

            addModel = model
            showAlert(self.kTitle3, holder: "", btnTitle: "搜索")
        }))
        
        alertCtrl.addAction(UIAlertAction(title: kTitle4, style: .default, handler: { [self] action in
            searchType = 0
            
            model.type = .result
            model.typeName = kTitle4

            addModel = model
            
            let warning = """
            -1 表示全部修改.
            1,3 表示修改第1个和第3个.
            1=10 表示第1修改到第10个.
            1++10&&ABC 表示从第1修改到第10个并内存地址出现尾数包含ABC一律修改.
            @A 表示修改地址尾数带有A的.
            ||1024 表示修改数值带有1024的.
            1,3//+4 表示修改第1个和第3个,并加或者减偏移量
            """
            
            showPromotion(title: "修改规则", promotion: warning, secondaryTitle: "选择您的修改方式")
                .appearance(promotionStyle: .color(.systemPink), placeholder: "")
                .confirm(title: "确定", style: .primary, fill: false, cancelTitle: nil) { indexs in
                    model.indexs = indexs
                    showAlert("数值修改", holder: "", btnTitle: "修改")
                    
            }.shouldBecomeFirstResponder()
            
        }))
        
        alertCtrl.addAction(UIAlertAction(title: kTitle5, style: .default, handler: { [self] action in
            searchType = 0
            
            model.type = .clear
            model.typeName = kTitle5
            model.clearOpen = true
            
            addModel = model
            
            dataArray.append(addModel!)
            tableView.reloadData()

            self.model!.steps.add(addModel!)

            addModel = nil

            VMOneKeyTool.save()
        }))
        
        alertCtrl.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))

        if UIDevice.deviceIsPhone() {
            // iPhone
            present(alertCtrl, animated: true)
        } else {
            // iPad
            let popover = alertCtrl.popoverPresentationController
            popover?.barButtonItem = btn
            present(alertCtrl, animated: true)
        }
    }
    
    func validatePassword(_ password: String) -> Bool {
        return true
    }
    
    // MARK: - 展示弹框
        
    func showAlert(_ title: String?, holder: String?, btnTitle: String?) {
        
        if searchType == 1 {
            textField1.text = holder
        } else {
            textField1.text = ""
        }
        
        let config = JHUIAlertConfig()
        config.title.text = title
        config.title.bottomPadding = 78
        config.dismissWhenTapOut = false
        config.contentViewWidth = 280
        config.contentViewCornerRadius = 15
        config.title.color = UIColor.dynamicColor(.black, darkColor: .white)
        
        let btn1 = JHUIAlertButtonConfig.init(title: "取消", color: nil, font: nil, image: nil, handle: nil)
        let btn2 = JHUIAlertButtonConfig(title: btnTitle, color: nil, font: nil, image: nil, handle: { [weak wk = self] in
            wk!.sureAction()
        })
        config.buttons = [btn1!, btn2!]

        let alertView = JHUIAlertView(config: config)
        alertView?.addCustomView({ [self] alertView, contentViewRect, titleLabelRect, contentLabelRect in

            self.segment.top = titleLabelRect.maxY + 5
            self.segment.centerX = titleLabelRect.midX

            self.textField1.top = self.segment.bottom + 5
            self.textField1.width = contentViewRect.width - 20
            self.textField1.centerX = self.segment.centerX

            alertView?.contentView?.addSubview(self.segment)
            alertView?.contentView?.addSubview(self.textField1)
        })
        
        alertView?.show(in: view.window)
        alertView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEdit)))
        self.alertView = alertView
    }
    
    func sureAction() {
        
        if searchType == 0 {
            let value = textField1.text
            let key = segment.titleForSegment(at: segment.selectedSegmentIndex)

            addModel!.key = key!
            addModel!.value = value!

            dataArray.append(addModel!)
            tableView.reloadData()

            model!.steps.add(addModel!)

            addModel = nil

            VMOneKeyTool.save()
        } else if searchType == 1 {
            let value = textField1.text
            let key = segment.titleForSegment(at: segment.selectedSegmentIndex)

            addModel!.key = key!
            addModel!.value = value!

            tableView.reloadData()

            addModel = nil

            VMOneKeyTool.save()
        }
    }
    
    @objc func endEdit() {
        alertView!.endEditing(true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: "header")
        }

        view?.textLabel?.text = "第 \(NSNumber(value: section + 1)) 步"
        return view
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resueID")
        }

        let model = dataArray[indexPath.section] as! VMOneKeySubModel
        
        NSLog("memlog: model = \(model)")
        
        var type = ""
        if (model.key.count != 0) {
            type = "[\(model.key)] "
        }
        
        var indexs = ""
        if (model.indexs.count != 0) {
            if model.indexs == "-1" {
                indexs = "全部修改"
            }
            else if model.indexs.contains("//") {
                let arr = model.indexs.components(separatedBy: "//")
                if arr.count == 2 {
                    let str1 = arr[0] // 1,3
                    let str2 = arr[1] // -214
                    
                    if str1 == "-1" {
                        indexs = "全部修改, 偏移量: \(str2)"
                    }else{
                        indexs = "修改第 \(str1) 个, 偏移量:\(str2)"
                    }
                }
            }
            else if model.indexs.contains("=") {
                
                let start = Int(model.indexs.components(separatedBy: "=").first ?? "") ?? 0 - 1
                let end = Int(model.indexs.components(separatedBy: "=").last ?? "") ?? 0 - 1

                indexs = "修改第 \(start) 到第 \(end) 个"
                
            }
            else if model.indexs.contains("@") {
                
                let arr = model.indexs.components(separatedBy: "@")
                indexs = "修改地址尾数带有: \(arr[1]) 的"
                
            }else if model.indexs.contains("||") {
                
                let arr = model.indexs.components(separatedBy: "||")
                indexs = "修改数值带有: \(arr[1]) 的"
                
            }else if model.indexs.contains("++") && model.indexs.contains("&&") {
                
                let start = Int(model.indexs.components(separatedBy: "++").first ?? "") ?? 0 - 1
                let end = Int(model.indexs.components(separatedBy: "++").last ?? "") ?? 0 - 1
                
                let arr = model.indexs.components(separatedBy: "&&")
                
                indexs = "修改 \(start) 到 \(end) 个,并修改地址尾数有: \(arr[1])"
            }else {
                indexs = "修改: \(model.indexs) 个"
            }
        }
        
        cell?.textLabel?.text = "\(model.typeName)\(type)\(model.value)"
        cell?.accessoryView = nil
        
        // 是修改结果 加个开关
        if model.type == .result {
            let swit = UISwitch()
            swit.tag = indexPath.section
            swit.setOn(model.switOpen, animated: false)
            swit.addTarget(self, action: #selector(switChange), for: .valueChanged)
            cell?.accessoryView = swit
            cell?.detailTextLabel?.text = "\(indexs)"
            cell?.detailTextLabel?.textColor = UIColor.gray
        }
        
        if model.type == VMOneKeySubType.clear {
            cell?.textLabel?.text = "清除结果"
            cell?.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = dataArray[indexPath.section] as! VMOneKeySubModel
        let title = model.typeName
        
        if title == kTitle1 {
            searchType = 1
            model.type = .numberSearch
            model.typeName = kTitle1

            addModel = (model)
            showAlert(kTitle1, holder: model.value, btnTitle: "搜索")
        }
        
        else if title == kTitle2 {
            UIAlertController.showAlert(kTitle2, message: "", holder: model.value, buttonTitle: "确定", handler: { [self] text in

                if text!.count == 0 {
                    return
                }

                model.key = ""
                model.value = (text)!
                
                tableView.reloadData()
                addModel = nil
                VMOneKeyTool.save()
            })
        }
        
        else if title == kTitle3 {
            searchType = 1
            model.type = .nearSearch
            model.typeName = kTitle3

            addModel = (model)
            showAlert("邻近搜索", holder: model.value, btnTitle: "搜索")
        }
        
        else if title == kTitle4 {
            searchType = 1
            model.type = .result
            model.typeName = kTitle4

            addModel = (model)
            
            let warning = """
            -1 表示全部修改.
            1,3 表示修改第1个和第3个.
            1=10 表示第1修改到第10个.
            1++10&&ABC 表示从第1修改到第10个并内存地址出现尾数包含ABC一律修改.
            @A 表示修改地址尾数带有A的.
            ||1024 表示修改数值带有1024的.
            1,3//+4 表示修改第1个和第3个,并加或者减偏移量
            """
            
            showPromotion(title: "修改规则", promotion: warning, secondaryTitle: "选择您的修改方式")
                .appearance(promotionStyle: .color(.systemPink), placeholder: "")
                .confirm(title: "确定", style: .primary, fill: false, cancelTitle: nil) { [self] indexs in
                    model.indexs = indexs
                    showAlert("数值修改", holder: model.value, btnTitle: "修改")
                    
            }.shouldBecomeFirstResponder()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = dataArray[indexPath.section] as! VMOneKeySubModel

            dataArray.remove(at: indexPath.section)
            tableView.reloadData()

            self.model?.steps.remove(model)
        }
    }
    
    // MARK: - 开关事件
    
    @objc func switChange(_ swit: UISwitch) {
        let section = swit.tag
        let model = dataArray[section] as! VMOneKeySubModel
        model.switOpen = swit.isOn
    }

    // MARK: - 懒加载
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 45
        tableView.sectionHeaderHeight = 30
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = true
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 增加顶部距离
        tableView.tableHeaderView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
            view.backgroundColor = UIColor.clear
            return view
        }()
        
        return tableView
    }()
    
    lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: VMTool.share().allKeys())
        segment.selectedSegmentIndex = 0
        
        typeKeyValues = VMTool.share().keyValues()
        return segment
    }()

    lazy var textField1: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.placeholder = "数值"
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .search
        textField.delegate = self
        textField.backgroundColor = UIColor.dynamicColor(.white, darkColor: .systemGray5)
        
        weak var wk = self
        textField.jh_keyboard.changeBlock = { name, beginFrame, endFrame, duration, curve in
            if name == UIResponder.keyboardWillShowNotification {
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    let offset: CGFloat = (wk!.alertView?.contentView.bottom)! - endFrame.origin.y
                    if offset > 0 {
                        wk!.offsetY = offset
                        wk!.alertView?.contentView.bottom -= offset + 50
                    }
                })
            } else if name == UIResponder.keyboardWillHideNotification {
                UIView.animate(withDuration: TimeInterval(duration), animations: {
                    wk!.alertView?.contentView.center = CGPoint(x: wk!.alertView!.centerX, y: wk!.alertView!.centerY + 50)
                })
            }
        }
        
        return textField
    }()
}

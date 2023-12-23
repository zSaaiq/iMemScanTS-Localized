//
//  VMRecordCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit

class VMRecordCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var kWidth = UIScreen.main.bounds.size.width
    
    var dataArray: [Any] = []
    var alertView: JHUIAlertView?
    var numText:String = ""                // 数值搜索内容
    var typeKeyValues:[AnyHashable : Any]? // 类型
    var modifyType:NSInteger = 0
    var offsetY: CGFloat = 0.0
    
    var timerOn: Bool = false // 定时器是否开启
    
    init() {
        super.init(nibName: nil, bundle: nil)
        dataArray = []
        addNotification()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("Record", comment: "")
        setupViews()
    }
    
    // MARK: - 视图
    
    func setupViews() {
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        //navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
        
        view.addSubview(tableView)
        view.addSubview(menuView)
        
        tableView.contentInset = UIEdgeInsets(top: menuView.frame.height, left: 0, bottom: 0, right: 0)
    }
    
    // MARK: - 事件
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(addRecord(_:)), name: NSNotification.Name("kSaveRecordNotification"), object: nil)
    }
    
    @objc func addRecord(_ noti: Notification?) {
        guard let model = noti?.object as? MemModel else {
            return
        }

        let flag = dataArray.contains { (element) -> Bool in
            let m = element as! MemModel
            if m.address == model.address {
                return true
            }
            return false
        }

        if flag == false {
            dataArray.append(model)
            tableView.reloadData()
            startTimer()
        }
    }
    
    @objc func buttonAction(_ button: UIButton?) {
        guard let title = button?.currentTitle else { return }

        switch title {
        case NSLocalizedString("Script", comment: ""):
            oneKeyModify()
        case NSLocalizedString("Adjust", comment: ""):
            oneKeyOffset()
        case NSLocalizedString("Modify All", comment: ""):
            if dataArray.count > 0 {
                allModify()
            }
        case NSLocalizedString("Clear", comment: ""):
            if dataArray.count > 0 {
                clearAction()
            }
        default:
            break
        }
    }
    
    // MARK: - 清除结果
    
    func clearAction() {
        dataArray.removeAll()
        tableView.reloadData()
    }
    
    // MARK: - 一键修改
    
    func oneKeyModify() {
        navigationController?.pushViewController(VMOneKeyGroupCtrl(), animated: true)
    }

    // MARK: - 偏移
    
    func oneKeyOffset() {
        
        if dataArray.count == 0 {
            UIAlertController.showAlert4(NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please add the save address first", comment: ""), btnTitle: "ok")
            return
        }
        
        UIAlertController.showAlert_Longpress(NSLocalizedString("Save list rebase", comment: ""), message: NSLocalizedString("Rule + / - For example input: +4", comment: ""), holder: NSLocalizedString("Offset", comment: ""), buttonTitle: NSLocalizedString("Set?", comment: ""), handler: { [self] text in
            let offset: String = text!
            
            for m in self.dataArray {
                let model = m as! MemModel
                
                // string -> unsigned long long
                let addr = model.address
                
                var a: mach_vm_address_t = 0
                let scanner = Scanner(string: addr)
                
                if addr.hasPrefix("0x") || addr.hasPrefix("0X") {
                    scanner.scanHexInt64(&a)
                } else {
                    scanner.scanUnsignedLongLong(&a)
                }
                
                var b: mach_vm_address_t = 0
                let symb = offset.substring(to: 1) // + , -
                let strB = offset.substring(from: 1) // 数值
                let scannerB = Scanner(string: strB)
                scannerB.scanHexInt64(&b)
                
                // 偏移
                if symb == "-" {
                    a -= b
                } else {
                    a += b
                }
                
                // fffffffff = 小写转大写 = FFFFFFFFF
                var tempStr = String(a, radix: 16)
                tempStr = tempStr.uppercased()
                
                model.address = "0x\(tempStr)"
            }
            
            tableView.reloadData()
        })
    }

    // MARK: - 全改
    
    func allModify() {
        modifyType = 1
        showAlert(NSLocalizedString("Modify all", comment: ""), holder: nil, buttonTitle: NSLocalizedString("Revise", comment: ""), table: tableView, indexPath: nil)
    }
    
    // MARK: - 定时修改
    func shouldModify() {
        for m in dataArray {
            let model = m as! MemModel
            if model.selected {
                VMTool.share().modifyValue(model.value, address: model.address, type: model.type)
            }
        }
    }
    
    // MARK: - 定时器
    
    private var timer: DispatchSourceTimer?

    func startTimer() {
        if timerOn {
            return
        }
        timerOn = true
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer?.schedule(deadline: .now(), repeating: .seconds(VMTool.share().duration1()))
        timer?.setEventHandler(handler: { [self] in
            shouldModify()
        })

        timer?.resume() // 启用定时器
    }
    
    func stopTimer() {
        // 判断其他的
        var flag = false
        for model in dataArray {
            let m = model as! MemModel
            if m.selected {
                flag = true
            }
        }
        
        if flag == false {
            timerOn = false
            timer?.cancel() // 销毁定时器
        }
    }
    
    // MARK: - 开关切换
    
    @objc func switChanged(_ swit: UISwitch?) {
        let tag = swit?.tag ?? 0
        let model = dataArray[tag] as! MemModel
        model.selected = swit?.isOn == true

        if swit!.isOn {
            startTimer()
        }else {
            stopTimer()
        }
    }
    
    // MARK: - 修改弹窗
    
    func showAlert(_ title: String?, holder: String?, buttonTitle btnTitle: String?, table tableView: UITableView?, indexPath: IndexPath?) {

        textField1.text = holder

        let config = JHUIAlertConfig()
        config.title.text = title
        config.title.bottomPadding = 78
        config.dismissWhenTapOut = false
        config.contentViewWidth = 280
        config.contentViewCornerRadius = 15
        config.title.color = UIColor.dynamicColor(.black, darkColor: .white)
        
        let btn1 = JHUIAlertButtonConfig.init(title: NSLocalizedString("Cancel", comment: ""), color: nil, font: nil, image: nil, handle: nil)
        let btn2 = JHUIAlertButtonConfig(title: btnTitle, color: nil, font: nil, image: nil, handle: { [weak wk = self] in
            wk!.modifyAction(tableView ,index:indexPath)
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
    
    @objc func endEdit() {
        alertView!.endEditing(true)
    }
    
    func modifyAction(_ tableView: UITableView?, index indexPath: IndexPath?) {
        
        if modifyType == 0 {
            
            let text = textField1.text
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            let type = typeKeyValues![key] as! Int32

            let model = dataArray[indexPath!.row] as! MemModel
            model.value = text!
            model.type = VMMemValueType(rawValue: VMMemValueType.RawValue(type))

            VMTool.share().modifyValue(model.value, address: model.address, type: model.type)

            let cell = tableView!.cellForRow(at: indexPath!)
            cell?.textLabel?.text = model.recordName
            cell?.detailTextLabel?.text = "\(model.address)：\(model.value)"

        } else if modifyType == 1 {
            
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            
            let type = typeKeyValues![key] as! Int32
            
            for m in self.dataArray {
                let model = m as! MemModel
                model.value = textField1.text!
                model.type = VMMemValueType(rawValue: VMMemValueType.RawValue(type))
                VMTool.share().modifyValue(model.value, address: model.address, type: model.type)
            }
            
            tableView!.reloadData()
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resueID")
            cell?.accessoryView = {
                let swit = UISwitch()
                swit.addTarget(self, action: #selector(switChanged(_:)), for: .valueChanged)
                swit.tag = 100
                return swit
            }()
        }
        
        let model = dataArray[indexPath.row] as! MemModel
        
        let swit = cell?.accessoryView as? UISwitch
        swit?.tag = indexPath.row
        swit?.setOn(model.selected, animated: false)
        
        cell?.textLabel?.text = model.recordName
        cell?.detailTextLabel?.text = "\(model.address)：\(model.value)"
        cell!.accessoryType = .detailButton
        
        if model.recordName.count > 0 {
        } else {
            cell?.detailTextLabel?.textColor = UIColor.gray
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataArray[indexPath.row] as? MemModel

        // 单个修改
        modifyType = 0
        if (model?.recordName.count)! > 0 {
            var title: String? = nil
            if let address = model?.address {
                let modifyValueTitle = NSLocalizedString("modify Value", comment: "Modify Value")
                let title = String(format: modifyValueTitle, address)
            }
            showAlert(title, holder: model?.value, buttonTitle: NSLocalizedString("Modify", comment: ""), table: tableView, indexPath: indexPath)
        } else {
            var title: String? = nil
            if let recordName = model?.recordName {
                let modifyValueTitle = NSLocalizedString("modifyValueRecord", comment: "Modify Value Record")
                let title = String(format: modifyValueTitle, recordName)
            }
            showAlert(title, holder: model?.value, buttonTitle: NSLocalizedString("Modify", comment: ""), table: tableView, indexPath: indexPath)
        }
    }
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer?) {
        let indexPath = tableView.indexPathForRow(at: gesture?.location(in: gesture?.view) ?? CGPoint.zero)
        if indexPath == nil {
            return
        }
        
        let model = dataArray[indexPath!.row] as! MemModel
        let alertCtrl = UIAlertController(title: nil, message: "Manage \((model as AnyObject).address ?? "")", preferredStyle: .actionSheet) //Not localized
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Adjust base address", comment: ""), style: .default, handler: { [self] action in
            
            let title = NSLocalizedString("Save list rebase", comment: "")
            UIAlertController.showAlert_Longpress(title, message: nil, holder: NSLocalizedString("Offset", comment: ""), buttonTitle: NSLocalizedString("Set?", comment: ""), handler: { [self] text in
                let offset: String = text!
                
                // string -> unsigned long long
                let addr = model.address
                
                var a: mach_vm_address_t = 0
                let scanner = Scanner(string: addr)
                
                if addr.hasPrefix("0x") || addr.hasPrefix("0X") {
                    scanner.scanHexInt64(&a)
                } else {
                    scanner.scanUnsignedLongLong(&a)
                }
                
                var b: mach_vm_address_t = 0
                let symb = offset.substring(to: 1) // + , -
                let strB = offset.substring(from: 1) // 数值
                let scannerB = Scanner(string: strB)
                scannerB.scanHexInt64(&b)
                
                // 偏移
                if symb == "-" {
                    a -= b
                } else {
                    a += b
                }
                
                // fffffffff = 小写转大写 = FFFFFFFFF
                var tempStr = String(a, radix: 16)
                tempStr = tempStr.uppercased()
                
                model.address = "0x\(tempStr)"

                let cell = self.tableView.cellForRow(at: indexPath!)
                cell?.textLabel?.text = model.recordName
                cell?.detailTextLabel?.text = "\(model.address)：\(model.value)"
                if model.recordName.count > 0 {
                } else {
                    cell?.detailTextLabel?.textColor = UIColor.gray
                }
            })
        }))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Modify name", comment: ""), style: .default, handler: { [self] action in
            
            let title = "Modify name \(model.address)" //Not localized
            UIAlertController.showAlert_Longpress(title, message: nil, holder: NSLocalizedString("Name", comment: ""), buttonTitle: NSLocalizedString("Revise", comment: ""), handler: { [self] text in
                model.recordName = text ?? ""

                let cell = self.tableView.cellForRow(at: indexPath!)
                cell?.textLabel?.text = text
                cell?.detailTextLabel?.text = "\(model.address)：\(model.value)"
                if model.recordName.count > 0 {
                } else {
                    cell?.detailTextLabel?.textColor = UIColor.gray
                }
            })
        }))
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("View memory", comment: ""), style: .default, handler: { [self] action in
            // 传送地址
            let model = self.dataArray[indexPath!.row] as? MemModel
            let dic = [
                "address": model?.address
            ]
            NotificationCenter.default.post(name: NSNotification.Name("kVMCheckAddress"), object: dic)

            // 切换页面
            self.tabBarController?.selectedIndex = 3
        }))
        
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Delete save", comment: ""), style: .destructive, handler: { [self] action in
            self.dataArray.remove(at: indexPath!.row)
            self.tableView.reloadData()
        }))

        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        
        if UIDevice.deviceIsPhone() {
            // iPhone
            present(alertCtrl, animated: true)
        } else {
            // iPad
            let rectInTableview = tableView.rectForRow(at: indexPath!)
            let rectInSuperview = tableView.convert(rectInTableview, to: tableView.superview)

            let popover = alertCtrl.popoverPresentationController
            popover?.sourceView = tableView.superview
            popover?.sourceRect = rectInSuperview
            popover?.permittedArrowDirections = .up
            present(alertCtrl, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: - 懒加载
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))

        return tableView
    }()
    lazy var textField1: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = .roundedRect
        textField.placeholder = NSLocalizedString("numerical value", comment: "")
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
    
    lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: VMTool.share().allKeys())
        segment.selectedSegmentIndex = 0
        typeKeyValues = VMTool.share().keyValues()
        return segment
    }()

    lazy var menuView: UIView = {
        let y = (navigationController?.navigationBar.frame.maxY)! + 60
        let view = UIView()
        view.frame = CGRect(x: 15, y: y, width: self.view.frame.width - 30, height: 44)
        view.backgroundColor = UIColor.dynamicColor(.white, darkColor: UIColor.opaqueSeparator)
        view.layer.cornerRadius = 10
        
        let titles = [
            NSLocalizedString("Clear", comment: ""),
            NSLocalizedString("Modify All", comment: ""),
            NSLocalizedString("Adjust", comment: ""),
            NSLocalizedString("Script", comment: "")
        ]
        //let width = UIScreen.main.bounds.size.width * 0.25
        let width = view.frame.width * 0.25

        for i in 0..<titles.count {
            let button = UIButton(type: .system)
            button.frame = CGRect(x: CGFloat(i) * width, y: 0, width: width, height: 44)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(titles[i], for: .normal)
            button.tintColor = UIColor.dynamicColor(.black, darkColor: .white)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: UIControl.Event(rawValue: 1 << 6))
            view.addSubview(button)
        }
        return view
    }()
}


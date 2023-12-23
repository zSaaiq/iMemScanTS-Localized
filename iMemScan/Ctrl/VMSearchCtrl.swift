//
//  VMSearchCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit

class VMSearchCtrl: UITableViewController, UITextFieldDelegate {

    var dataArray: [Any] = []
    
    var alertView: JHUIAlertView?
    var button1: UIButton?
    var button2: UIButton?
    var button3: UIButton?
    var button4: UIButton?
    
    var numText:String = ""                // 数值搜索内容
    var typeKeyValues:[AnyHashable : Any]? // 类型
    
    var pageIndex:NSInteger = 0
    var totalCount:NSInteger = 0
    
    var offsetY: CGFloat = 0.0
    var searchType:NSInteger = 0
    var modifyType:NSInteger = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = ""
        
        pageIndex = 1
        totalCount = 20
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if dataArray.count > 0 {
            Refresh()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        loadingView.center = tableView.center
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        // 刷新
        dataArray = []
        Refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图
    
    func setupViews() {
        
        //view.addSubview(tableView)
        tableView.rowHeight = 44.4
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))
        view.addSubview(loadingView)
        loadingView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        loadingView.center = tableView.center

        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(pulldownRefresh))
        // 初始化文字
        header.setTitle(NSLocalizedString("Pull down to refresh", comment: ""), for: .idle)
        header.setTitle(NSLocalizedString("Release to refresh", comment: ""), for: .pulling)
        header.setTitle(NSLocalizedString("Refreshing data...", comment: ""), for: .refreshing)
        tableView.mj_header = header

        let footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(pullUpRefresh))
        footer.triggerAutomaticallyRefreshPercent = 0.0
        tableView.mj_footer = footer

        let titles = [
            NSLocalizedString("Modify All", comment: ""),
            NSLocalizedString("Select", comment: ""),
            NSLocalizedString("Value Search", comment: ""),
            NSLocalizedString("Nearby Search", comment: "")
        ]
        var items: [AnyHashable]? = []
        
        for i in 0..<titles.count {
            let button = UIButton(type: .system)
            
            if titles[i] == NSLocalizedString("Modify All", comment: "") || titles[i] == NSLocalizedString("Select", comment: "") {
                button.frame = CGRect(x: 0, y: 0, width: 50, height: 25)
            }

            if titles[i] == NSLocalizedString("Value Search", comment: "") || titles[i] == NSLocalizedString("Nearby Search", comment: "") {
                button.frame = CGRect(x: 0, y: 0, width: 80, height: 25)
            }
            
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(titles[i], for: UIControl.State(rawValue: 0))
            button.tag = i
            button.layer.cornerRadius = 12.5
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
            button.addTarget(self, action: #selector(buttonAction(_:)), for: UIControl.Event(rawValue: 1 << 6))

            let item = UIBarButtonItem(customView: button)
            
            if i == 0 {
                button1 = button
            } else if i == 1 {
                button2 = button
            } else if i == 2 {
                button3 = button
            } else if i == 3 {
                button4 = button
            }
            
            items?.append(item)
        }
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.leftBarButtonItems = (items as! [UIBarButtonItem])
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: {
            let button = UIButton(type: .system)
            button.frame = .init(x: 0, y: 0, width: 50, height: 25)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(NSLocalizedString("Clear", comment: ""), for: .normal)
            button.setTitle(NSLocalizedString("Clear", comment: ""), for: .highlighted)
            button.layer.cornerRadius = 12.5
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
            button.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
            return button
        }())
    }
    
    
    // MARK: - 事件
    
    @objc func buttonAction(_ button: UIButton?) {
        let title = button?.currentTitle
        
        switch title {
        case NSLocalizedString("Clear Results", comment: ""):
            clearAction()
        case NSLocalizedString("Value Search", comment: ""):
            searchAction()
        case NSLocalizedString("Modify All", comment: ""):
            if dataArray.count > 0 {
                allModifyAction()
            }
        case NSLocalizedString("Select", comment: ""):
            if dataArray.count > 0 {
                button?.setTitle(NSLocalizedString("Confirm", comment: ""), for: UIControl.State(rawValue: 0))
                tableView.setEditing(true, animated: true)
                SwitchButto()
            }
        case NSLocalizedString("Confirm", comment: ""):
            partModifyAction(button)
        case NSLocalizedString("Nearby Search", comment: ""):
            if dataArray.count > 0 {
                nearSearchAction()
            }
        case NSLocalizedString("Select First Half", comment: ""):
            if dataArray.count > 0 {
                self.resetSelected()
                
                for i in 0..<Int(Double(dataArray.count) * 0.5) {
                    let m = dataArray[i] as! MemModel
                    m.selected = true
                }
                
                self.tableView.reloadData()
            }
        case NSLocalizedString("Select Second Half", comment: ""):
            if dataArray.count > 0 {
                self.resetSelected()
                
                let s = Int(Double(dataArray.count) * 0.5)
                for i in s..<dataArray.count {
                    let m = dataArray[i] as! MemModel
                    m.selected = true
                }
                
                self.tableView.reloadData()
            }
        case NSLocalizedString("Reset", comment: ""):
            if dataArray.count > 0 {
                self.resetSelected()
                self.tableView.reloadData()
            }
        default:
            break
        }
    }

    
    func SwitchButto() {
        
        var titles: [AnyHashable]? = nil
        titles = [
            NSLocalizedString("Reset", comment: ""),
            NSLocalizedString("Confirm", comment: ""),
            NSLocalizedString("Select First Half", comment: ""),
            NSLocalizedString("Select Second Half", comment: "")
        ]
        let buttons = [button1, button2, button3, button4]
        for i in 0..<(titles?.count ?? 0) {
            let btn = buttons[i]
            btn?.setTitle(titles?[i] as? String, for: UIControl.State(rawValue: 0))
        }
    }
    
    // MARK: - 重置所有选择
    func resetSelected() {
        for model in dataArray {
            let m = model as! MemModel
            m.selected = false
        }
    }
    
    // MARK: - 清除结果
    
    @objc func clearAction() {
        dataArray.removeAll()
        tableView.reloadData()

        VMTool.share().reset()
    }

    // MARK: - 数值搜索
    func searchAction() {
        searchType = 0
        showAlert(NSLocalizedString("Numeric search", comment: ""))
    }

    // MARK: - 邻近搜索
    
    func nearSearchAction() {
        
        if dataArray.count > 1000000 {
            UIAlertController.showAlert4("🙄", message: NSLocalizedString("Please click clear. I already have 1 million data and you are searching for someone nearby.", comment: ""), btnTitle: "ok")
            return
        }
        
        searchType = 1
        showAlert(NSLocalizedString("Proximity search", comment: ""))
    }
    
    // MARK: - 搜索弹框
    
    func showAlert(_ title: String?) {
        textField1.text = ""

        let config = JHUIAlertConfig()
        config.title.text = title
        config.title.bottomPadding = 78
        config.dismissWhenTapOut = false
        config.contentViewWidth = 280
        config.contentViewCornerRadius = 15
        config.title.color = UIColor.dynamicColor(.black, darkColor: .white)
        
        let btn1 = JHUIAlertButtonConfig.init(title: NSLocalizedString("Cancel", comment: ""), color: nil, font: nil, image: nil, handle: nil)
        let btn2 = JHUIAlertButtonConfig(title: NSLocalizedString("Search", comment: ""), color: nil, font: nil, image: nil, handle: { [weak wk = self] in
            wk!.refreshAction()
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
    
    func refreshAction() {
        alertView!.endEditing(true)

        if textField1.text!.count == 0 {
            return
        }
        
        if searchType == 0 {
            loadingView.startAnimating()

            let text = textField1.text
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            
            let type = typeKeyValues![key] as! Int32
            let comp = VMMemComparisonEQ
            
            VMTool.share().searchValue(text!, type: VMMemValueType(rawValue: VMMemValueType.RawValue(type)), comparison: comp, callback: { [self] count, array in
                
                if array.count != 0 {
                    self.dataArray.removeAll()
                    (array as NSArray).enumerateObjects({ model, idx, stop in
                        (model as! MemModel).key = key
                    })

                    self.dataArray.append(contentsOf: array)
                    self.tableView.reloadData()
                }

                self.loadingView.stopAnimating()
            })
        }
        else if searchType == 1 {
            loadingView.startAnimating()

            let text = textField1.text
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            
            let type = typeKeyValues![key] as! Int32
            let range = VMTool.share().rangeValue

            VMTool.share().nearMemSearch(text!, type: VMMemValueType(rawValue: VMMemValueType.RawValue(type)), range: range(), callback: { [self] count, array in
                
                if array.count == 0 {
                    clearAction()
                }
                
                if array.count != 0 {

                    (array as NSArray).enumerateObjects({ model, idx, stop in
                        (model as! MemModel).key = key
                    })
                    
#if false
                    for m1 in self.dataArray {
                        for m2 in array {
                            let first = m1 as! MemModel
                            let second = m2 as! MemModel

                            if first.address == second.address {
                                second.type = first.type
                                second.key = first.key
                                break
                            }
                        }
                    }
#else
#endif
                    self.dataArray.removeAll()
                    self.dataArray.append(contentsOf: array)
                    self.tableView.reloadData()
                }

                self.loadingView.stopAnimating()
            })
        }
    }
    
    // MARK: - 全改
    func allModifyAction() {
        modifyType = 1
        showAlert(NSLocalizedString("Modify All", comment: ""), holder: "", buttonTitle: NSLocalizedString("Complete change", comment: ""), indexPath: nil)
    }
    
    // MARK: - 批量修改
    
    func partModifyAction(_ button: UIButton?) {
        button?.setTitle(NSLocalizedString("Choose", comment: ""), for: UIControl.State(rawValue: 0))
        
        var titles: [AnyHashable]? = nil
        titles = [
            NSLocalizedString("Modify All", comment: ""),
            NSLocalizedString("Select", comment: ""),
            NSLocalizedString("Numeric Search", comment: ""),
            NSLocalizedString("Nearby Search", comment: "")
        ]
        let buttons = [button1, button2, button3, button4]
        for i in 0..<(titles?.count ?? 0) {
            let btn = buttons[i]
            btn?.setTitle(titles?[i] as? String, for: UIControl.State(rawValue: 0))
        }
        
        tableView.setEditing(false, animated: true)

        var flag = false
        for model in dataArray {
            if (model as AnyObject).selected {
                flag = true
                break
            }
        }

        if flag {
            modifyType = 2
            showAlert(NSLocalizedString("Batch Edit", comment: ""), holder: "", buttonTitle: NSLocalizedString("Revise", comment: ""), indexPath: nil)
        }
    }
    
    // MARK: - 修改弹窗
    
    func showAlert(_ title: String?, holder: String?, buttonTitle btnTitle: String?, indexPath: IndexPath?) {
        textField1.text = holder

        let config = JHUIAlertConfig()
        config.title.text = title
        config.title.bottomPadding = 78
        config.dismissWhenTapOut = false
        config.contentViewWidth = 280
        config.contentViewCornerRadius = 15
        config.title.color = UIColor.dynamicColor(.black, darkColor: .white)
        
        let btn1 = JHUIAlertButtonConfig.init(title: "取消", color: nil, font: nil, image: nil, handle: nil)
        let btn2 = JHUIAlertButtonConfig(title: btnTitle, color: nil, font: nil, image: nil, handle: { [weak wk = self] in
            wk!.modifyAction(indexPath)
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
    
    func modifyAction(_ indexPath: IndexPath?) {
        
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
            tableView.reloadData()
        }
        else if modifyType == 1 {
            var flag:Bool = false
            var text:String = textField1.text!
            
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            
            let type = typeKeyValues![key] as! Int32
            
            if text.hasSuffix("++") && text.count > 2 {
                flag = true
                let t = text as NSString
                text = t.substring(to: t.length - 2)
            }
            
            for model in dataArray {
                (model as! MemModel).value = text
                (model as! MemModel).type = VMMemValueType(rawValue: VMMemValueType.RawValue(type))
                
                VMTool.share().modifyValue((model as! MemModel).value, address: (model as! MemModel).address, type: (model as! MemModel).type)
                
                if flag {
                    guard let val = Int(text) else {
                        return
                    }
                    
                    text = String.init(val+1)
                }
            }
            tableView.reloadData()
        }
        else if modifyType == 2 {
            
            var flag:Bool = false
            var text:String = textField1.text!
            
            guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
                return
            }
            
            let type = typeKeyValues![key] as! Int32
            
            if text.hasSuffix("++") && text.count > 2 {
                flag = true
                let t = text as NSString
                text = t.substring(to: t.length - 2)
            }
            
            for model in dataArray {
                if (model as! MemModel).selected {
                    (model as! MemModel).selected = false
                    (model as! MemModel).value = text
                    (model as! MemModel).type = VMMemValueType(rawValue: VMMemValueType.RawValue(type))

                    VMTool.share().modifyValue((model as! MemModel).value, address: (model as! MemModel).address, type: (model as! MemModel).type)

                    if flag {
                        guard let val = Int(text) else {
                            return
                        }
                        
                        text = String.init(val+1)
                    }
                }
            }
            tableView.reloadData()
        }
 
    }
    
    // MARK: - 下拉刷新
    
    @objc func pulldownRefresh() {
        
        VMTool.share().refresh(callback: { [self] count, array in
            if array.count != 0 {
                dataArray.removeAll()
                dataArray.append(contentsOf: array)
                tableView.reloadData()
            }
            tableView.mj_header?.endRefreshing()
        })
    }
    
    @objc func Refresh() {
        VMTool.share().refresh(callback: { [self] count, array in
            if array.count != 0 {
                dataArray.removeAll()
                dataArray.append(contentsOf: array)
                tableView.reloadData()
            }
        })
    }
    
    // MARK: - 上拉加载
    
    @objc func pullUpRefresh() {
        if dataArray.count > 0 {
            pageIndex += 1
            let total = pageIndex * 20
            if total < dataArray.count {
                totalCount = total
            } else {
                totalCount = dataArray.count
            }
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [self] in
            tableView.reloadData()
            tableView.mj_footer?.endRefreshing()
        })
    }
    
    // MARK: - 长按保存
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer?) {
        let indexPath = tableView.indexPathForRow(at: gesture?.location(in: gesture?.view) ?? CGPoint.zero)
        if indexPath == nil {
            return
        }
        
        let model = dataArray[indexPath!.row] as! MemModel
        let clone = model.clone()
    
        let title = "Save address " + (model.address)// not localized
        UIAlertController.showAlert_Longpress(title, message: nil, holder: NSLocalizedString("Name", comment: ""), buttonTitle: NSLocalizedString("Store", comment: ""), handler: { text in
            clone.recordName = text!

            NotificationCenter.default.post(name: NSNotification.Name("kSaveRecordNotification"), object: clone)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if totalCount < dataArray.count {
            return totalCount
        }
        
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resueID")
        }
        
        let model = dataArray[indexPath.row] as! MemModel

        cell?.textLabel?.text = "\(NSNumber(value: indexPath.row + 1)). \(model.address)"
        cell?.detailTextLabel?.text = "(\(model.value))"
        cell!.accessoryType = .detailButton
        cell?.detailTextLabel?.textColor = UIColor.gray
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.isEditing {
            let model = dataArray[indexPath.row] as? MemModel
            model?.selected = !(model?.selected)!
            model?.index = indexPath.row
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        // 单个修改
        modifyType = 0
        let model = dataArray[indexPath.row] as! MemModel
        let title = "Revise \(model.address)"
        showAlert(title, holder: model.value, buttonTitle: NSLocalizedString("Set?", comment: ""), indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewID = "header"
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableViewID)
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: tableViewID)
            view!.backgroundView = {
                let view = UIView()
                view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 20)
                return view
            }()
            view!.contentView.addSubview({
                let label = UILabel()
                label.frame = CGRect(x: -210, y: 0, width: 200, height: 20)
                label.text = "(0)"
                label.font = UIFont.boldSystemFont(ofSize: 15)
                label.textAlignment = .right
                label.autoresizingMask = .flexibleLeftMargin
                label.tag = 100
                return label
            }())
        }

        let label = view!.contentView.viewWithTag(100) as? UILabel
        label?.text = "(\(NSNumber(value: dataArray.count)))"

        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            let model = dataArray[indexPath.row] as? MemModel
            model?.selected = !(model?.selected)!
            model?.index = indexPath.row
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 多选
        let model = dataArray[indexPath.row] as! MemModel
        if tableView.isEditing {
            cell.setSelected(model.selected, animated: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: 1 | 2)!
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        print("===\(NSNumber(value: indexPath.row))")

        // 传送地址
        let model = dataArray[indexPath.row] as? MemModel
        let dic = [
            "address": model!.address
        ]
        NotificationCenter.default.post(name: NSNotification.Name("kVMCheckAddress"), object: dic)

        // 切换页面
        tabBarController?.selectedIndex = 3
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        alertView!.endEditing(true)
        alertView!.dismiss()
        refreshAction()
        return true
    }
    
    // MARK: - 懒加载
    
//    lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: view.bounds, style: .plain)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = 44
//        tableView.tableFooterView = UIView()
//        //tableView.showsVerticalScrollIndicator = false
//        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        tableView.tableFooterView = UIView()
//
//        headerRefreshView = tableView.addFCXRefreshHeader { [weak self] (refreshHeader) in
//            self?.pulldownRefresh()
//        }
//
//        footerRefreshView = tableView.addFCXRefreshAutoFooter { [weak self] (refreshFooter) in
//            self?.pullUpRefresh()
//        }
//
//        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))
//
//        return tableView
//    }()
    
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
    
    lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView.init(style: .medium)
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

}

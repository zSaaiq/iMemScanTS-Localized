//
//  VMMemCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit

class VMMemCtrl: UITableViewController, UISearchBarDelegate, UITextFieldDelegate {

    var dataArray: [Any] = []
    var alertView: JHUIAlertView?
    var numText:String = ""                // 数值搜索内容
    var typeKeyValues:[AnyHashable : Any]? // 类型
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = ""
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if dataArray.count > 0 {
            searchfor()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        segment.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        dataArray = []
        addNotification()
        
        if dataArray.count > 0 {
            NotificationCenter.default.addObserver(self, selector: #selector(searchfor), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 视图
    
    func setupViews() {
        
        tableView.rowHeight = 44
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:))))
        
        let titles = [NSLocalizedString("Clear", comment: "Clear action title")]
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
        
        navigationItem.leftBarButtonItems = items as? [UIBarButtonItem]
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationItem.titleView = searchbar
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: {
            let button = UIButton(type: .system)
            button.frame = .init(x: 0, y: 0, width: 50, height: 25)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
            button.setTitle(NSLocalizedString("Search", comment: ""), for: .highlighted)
            button.layer.cornerRadius = 12.5
            button.backgroundColor = .secondarySystemBackground
            button.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
            button.addTarget(self, action: #selector(searchfor), for: .touchUpInside)
            return button
        }())
    }
    
    // MARK: - 事件
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(searchAddress(_:)), name: NSNotification.Name("kVMCheckAddress"), object: nil)
    }
    
    @objc func searchAddress(_ noti: Notification?) {
        let dic = noti?.object as? [AnyHashable : Any]
        let address = dic?["address"] as? String
        searchbar.text = address
    }

    @objc func buttonAction(_ button: UIButton?) {
        if button?.tag == 0 {
            clearAction()
        }
    }

    // MARK: - 清除结果
    
    func clearAction() {
        dataArray.removeAll()
        tableView.reloadData()
        VMTool.share().reset()
    }
    
    // MARK: - 搜索
    
    @objc func searchfor() {
        searchbar.resignFirstResponder()

        if searchbar.text!.count == 0 {
            return
        }

        let text = searchbar.text
        guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
            return
        }
        let valueType = typeKeyValues![key] as! Int32
        var sType = VMMemSearchType_8

        let num = (Int((key as NSString).substring(from: 1)) ?? 8) / 8
        switch num {
            case 1:
                sType = VMMemSearchType_1
            case 2:
                sType = VMMemSearchType_2
            case 4:
                sType = VMMemSearchType_4
            case 8:
                sType = VMMemSearchType_8
            default:
                break
        }

        dataArray = VMTool.share().memory(text!, size: "4096", type: sType, valueType: VMMemValueType(rawValue: VMMemValueType.RawValue(valueType)))
        tableView.reloadData()
        tableView.estimatedSectionHeaderHeight = 0

        // 查找目标
        let arr = (dataArray as NSArray).value(forKey: "address") as! NSArray
        let index = arr.index(of: text as Any)
        if index != NSNotFound {
            // 滚动到指定位置
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .top, animated: true)
        }
    }
    
    // MARK: - 长按保存
    
    @objc func longPressAction(_ gesture: UIGestureRecognizer?) {
        let indexPath = tableView.indexPathForRow(at: gesture?.location(in: gesture?.view) ?? CGPoint.zero)
        if indexPath == nil {
            return
        }

        let model = dataArray[indexPath!.row] as! MemModel
        let clone = model.clone()

        let title = NSLocalizedString("Save address ", comment: "") + (model.address)
        UIAlertController.showAlert_Longpress(title, message: nil, holder: NSLocalizedString("Name", comment: ""), buttonTitle: NSLocalizedString("Store", comment: ""), handler: { text in
            clone.recordName = text!

            NotificationCenter.default.post(name: NSNotification.Name("kSaveRecordNotification"), object: clone)
        })
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "resueID")
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
        }

        let model = dataArray[indexPath.row] as! MemModel
        let text = "\(model.address): 0x\(model.value_16) (\(model.value))"
        
        cell?.textLabel?.text = text
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let model = dataArray[indexPath.row] as! MemModel

        guard let key = segment.titleForSegment(at: segment.selectedSegmentIndex) else {
            return
        }
        let valueType = typeKeyValues![key] as! Int32

        // 单个修改
        let title = String(format: NSLocalizedString("Modify address", comment: "Modify Address"), model.address)
        let alertCtrl = UIAlertController(title: title, message: "", preferredStyle: .alert)

        alertCtrl.addTextField(configurationHandler: { textField in
            textField.placeholder = model.value
            textField.text = model.value
            textField.clearButtonMode = .whileEditing
        })
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .default, handler: nil))
        alertCtrl.addAction(UIAlertAction(title: NSLocalizedString("Revise", comment: ""), style: .default, handler: { action in
            let textField = alertCtrl.textFields?[0]
            if textField!.text!.count == 0 {
                return
            }

            VMTool.share().modifyValue(textField!.text!, address: model.address, type: VMMemValueType(rawValue: VMMemValueType.RawValue(valueType)))

            let cell = tableView.cellForRow(at: indexPath)
            cell?.textLabel?.text = "\(model.address): 0x\(model.value_16) (\(model.value))"
            self.searchfor()
        }))

        present(alertCtrl, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tableViewID = "header"
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: tableViewID)
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: tableViewID)
            view!.addSubview(segment)
        }
        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchfor()
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchfor()
    }
    
    // MARK: - 懒加载
    
//    lazy var tableView: UITableView = {
//        let tableView = UITableView(frame: view.bounds, style: UITableView.Style(rawValue: 0)!)
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.rowHeight = 42
//        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        tableView.tableFooterView = UIView()
//
//        //[tableView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)]];
//
//        return tableView
//    }()
    
    lazy var searchbar: UISearchBar = {
        let search = UISearchBar(frame: CGRect(x: 0, y: 0, width: 180, height: 20))
        search.delegate = self
        search.backgroundImage = UIImage()
        search.placeholder = NSLocalizedString("Search address (hex)", comment: "")
        return search
    }()
    
    lazy var segment: UISegmentedControl = {
        let segment = UISegmentedControl(items: VMTool.share().allKeys())
        segment.selectedSegmentIndex = 0
        segment.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        typeKeyValues = VMTool.share().keyValues()
        segment.addTarget(self, action: #selector(click(_:)), for: .valueChanged)
        return segment
    }()
    
    @objc func click(_ seg: UISegmentedControl?) {
        let index = seg?.selectedSegmentIndex ?? 0
        switch index {
            case 0:
                searchfor()
            case 1:
                searchfor()
            case 2:
                searchfor()
            case 3:
                searchfor()
            case 4:
                searchfor()
            case 5:
                searchfor()
            default:
                break
        }
    }
}

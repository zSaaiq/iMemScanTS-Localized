//
//  VMTargetCtrl.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit

class VMTargetCtrl: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var dataArray: [Any] = []
    var dataArray2: [Any] = []
    var pname: String = ""
    
    init() {
        super.init(nibName: nil, bundle: nil)

        // 刷新
        NotificationCenter.default.addObserver(self, selector: #selector(buttonAction), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.title = NSLocalizedString("Processes", comment: "")
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        buttonAction()
    }
    
    // MARK: - 视图
    
    func setupViews() {
        
        buttonAction()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
//        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: {
//            let button = UIButton(type: .system)
//            button.frame = .init(x: 0, y: 0, width: 50, height: 25)
//            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
//            button.setTitle("刷新", for: .normal)
//            button.setTitle("刷新", for: .highlighted)
//            button.layer.cornerRadius = 12.5
//            button.backgroundColor = .secondarySystemBackground
//            button.tintColor = UIColor.dynamicColor(.gray, darkColor: UIColor.white)
//            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//            return button
//        }())
        
        view.addSubview(tableView)
    }
    
    @objc func buttonAction() {
        // 越狱环境
//        let pid = PidModel.runningProcesses()
//        NSLog("memlog: \(pid)")
        
        dataArray = PidModel.refreshModelArray()
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let arr = dataArray[section] as! Array<PidModel>
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "resueID")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "resueID")
        }
        
        let arr = dataArray[indexPath.section] as! Array<PidModel>
        let model = arr[indexPath.row]

        cell?.textLabel?.text = model.name
        //cell?.detailTextLabel?.text = model.pid
        cell?.detailTextLabel?.textColor = UIColor.gray
        
        let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        icon.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withTintColor(.systemGray).withRenderingMode(.alwaysOriginal)
        
        icon.clipsToBounds = true
        cell?.accessoryView = icon
        icon.isHidden = !(pname == model.pid)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let arr = dataArray[indexPath.section] as! Array<PidModel>
        let model = arr[indexPath.row]
        VMTool.share().setPid(Int32(model.pid)!, name: model.name)
        
        pname = model.pid
        //model!.selected = true
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if view == nil {
            view = UITableViewHeaderFooterView(reuseIdentifier: "header")
        }
        
        if section == 0 {
            view?.textLabel?.text = NSLocalizedString("User Apps", comment: "")
        }
        
        if section == 1 {
            view?.textLabel?.text = NSLocalizedString("System Apps", comment: "")
        }
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
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
        
        // 增加顶部距离
        tableView.tableHeaderView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
            view.backgroundColor = UIColor.clear
            return view
        }()
        
        return tableView
    }()
}

//
//  VMOneKeyCell.swift
//  iMemScan
//
//  Created by 李良林 on 2020/12/5.
//  Copyright © 2020 李良林. All rights reserved.
//

import UIKit

class VMOneKeyCell: UITableViewCell {

    let kOneKeySwitchEvent = "kOneKeySwitchEvent"
    var indexPath: IndexPath?
    var model: VMOneKeyModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        accessoryView = swit
    }
    
    func setModel(_ model: VMOneKeyModel) {
        self.model = model

        textLabel?.text = model.name
        swit.isOn = model.open == true
    }
    
    private var timer: DispatchSourceTimer?
    
    @objc func switChange(_ swit: UISwitch?) {
        
        let queue = DispatchQueue(label: "net.bujige.testQueue")
        
        queue.async(execute: { [self, weak wk = self] in
            wk!.model!.open = swit!.isOn
            //print("\(model!.open)")
            
//            if wk!.model!.open {
//                let kOneKeySwitchEvent = "kOneKeySwitchEvent"
//                wk!.jh_router(withSelector: kOneKeySwitchEvent, sender: nil, info: [
//                    "indexPath": wk!.indexPath as Any
//                ])
//            }
            
            // 打开才操作
            if wk!.model!.open {
                
                let str = textLabel?.text
                let str2 = str?.suffix(2)
                
                if (str2 == "定时") {
                    timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
                    timer?.schedule(deadline: .now(), repeating: .seconds(VMTool.share().duration()))
                    
                    timer?.setEventHandler(handler: {
                        let kOneKeySwitchEvent = "kOneKeySwitchEvent"
                        wk!.jh_router(withSelector: kOneKeySwitchEvent, sender: nil, info: [
                            "indexPath": wk!.indexPath as Any
                        ])
                    })
                    
                    timer?.resume() // 启用定时器
                } else {
                    let kOneKeySwitchEvent = "kOneKeySwitchEvent"
                    wk!.jh_router(withSelector: kOneKeySwitchEvent, sender: nil, info: [
                        "indexPath": wk!.indexPath as Any
                    ])
                }
            } else {
                timer?.cancel() // 销毁定时器
            }
        })
    }

    lazy var swit: UISwitch = {
        let swit = UISwitch()
        swit.addTarget(self, action: #selector(switChange(_:)), for: .valueChanged)
        return swit
    }()
}

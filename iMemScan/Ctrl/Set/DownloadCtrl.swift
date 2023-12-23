//
//  DownloadCtrl.swift
//  CircleProgressBarExample
//
//  Created by Liu Chuan on 2018/2/17.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit


/// URL ViewController.test2
private let urlString = "http://45.32.181.238/DEB/com.yiming.iMemScan.deb"
///
private let imemacan = "/var/mobile/Documents/iMemScan(Script)/iMemScan.deb"

class DownloadCtrl: UIViewController {
    
    /// CAShapeLayer定义
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    /// 脉动层
    private var pulsatigLayer: CAShapeLayer = CAShapeLayer()
    
    /// 百分比标签
    private var percentageLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("Update", comment: "")
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.width, height: 20))
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 12)
        label.text = "Copyright © 2021 yiming. All Rights Reserved."
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

// MARK: - View life cycle
extension DownloadCtrl {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { [self] in
            animatePulsatingLayer()
        })
        
        configNotificationObservers()
        configCircleLayers()
        configPercentageLabel()
        view.backgroundColor = UIColor.backgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
        view.addSubview(bottomLabel)
        view.addSubview(bottomLabel2)
        bottomLabel.bottom = self.view.height - 40
        bottomLabel.bottom = self.view.height - 20
    }
}

//MARK: - Animations
extension DownloadCtrl {
    
    /// 动画脉动层
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        // 动画当前值
        animation.toValue = 1.3
        // 动画持续时间
        animation.duration = 0.8
        // 动画的速度变化
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        // 动画结束时是否执行逆动画
        animation.autoreverses = true
        // 重复次数
        animation.repeatCount = Float.infinity
        // 添加动画
        pulsatigLayer.add(animation, forKey: "pulsing")
    }
}

//MARK: - Configure
extension DownloadCtrl {
    
    /// 配置通知观察者
    private func configNotificationObservers() {
        //注册程序进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnter), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// 配置圆形图层
    private func configCircleLayers() {
        
        pulsatigLayer = CreateCircleShapeLayer(strokeColor: .clear, fillColor: .pulsatingFillColor)
        view.layer.addSublayer(pulsatigLayer)
        
        animatePulsatingLayer()
        
        /// 跟踪图层
        let trackLayer = CreateCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        
        shapeLayer = CreateCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        // 将动画向左转90度
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    /// 配置百分比标签
    private func configPercentageLabel() {
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        view.addSubview(percentageLabel)
    }
    
    /// 开始下载文件
    private func beginDownloadingFile() {
        print("start working ...")
        shapeLayer.strokeEnd = 0
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        // 创建会话对象
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        guard let url = URL(string: urlString) else { return }
        // 根据会话对象创建task
        let downloadTask = urlSession.downloadTask(with: url)
        // 使用resume方法启动任务
        downloadTask.resume()
    }
    
}

//MARK: - Event handling
extension DownloadCtrl {
    
    /// 点击事件
    @objc private func handleTap() {
        
        //let fileManager = FileManager.default
        
        if percentageLabel.text == "更新" {
            
//            if fileManager.fileExists(atPath: imemacan) {
//                try! fileManager.removeItem(atPath: imemacan)
//            }
            
            runCmd(path: "/usr/bin/rm", args: ["-", imemacan])
            
            beginDownloadingFile()
        }else if percentageLabel.text == "安装"{
            //spawn(command: "/usr/bin/dpkg", args: ["dpkg", "-i", imemacan])
            //spawn(command: "/usr/bin/uicache", args: ["uicache", "-p", "/Applications/iMemScan.app"])
            
            runCmd(path: "/usr/bin/dpkg", args: ["-i", imemacan])
            runCmd(path: "/usr/bin/uicache", args: ["-p", "/Applications/iMemScan.app"])
        }
    }
    
    /// 处理通知
    @objc private func handleEnter() {
        animatePulsatingLayer()
    }
}

// MARK: - Create Circle Layer (ShapeLayer)
extension DownloadCtrl {
    
    /// 创建圆形图层(ShapeLayer)
    ///
    /// - Parameters:
    ///   - strokeColor: 绘制颜色
    ///   - fillColor: 填充颜色
    /// - Returns: CAShapeLayer
    private func CreateCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = view.center
        return layer
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadCtrl : URLSessionDownloadDelegate {
    
    /// 下载完成
    ///
    /// - Parameters:
    ///   - session: NSURLSession
    ///   - downloadTask: 里面包含请求信息，以及响应信息
    ///   - location: 下载后自动帮我保存的地址
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print ("Finished downloading file. Save at\(location.path)")
        let locationPath = location.path
        
        runCmd(path: "/usr/bin/cp", args: [locationPath, imemacan])
        
//        let fileManager = FileManager.default
//
//        if fileManager.fileExists(atPath: imemacan) {
//            try! fileManager.moveItem(atPath: locationPath, toPath: imemacan)
//        }else{
//            try! fileManager.createDirectory(atPath: "/var/mobile/Documents/iMemScan(Script)", withIntermediateDirectories: true, attributes: nil)
//            try! fileManager.moveItem(atPath: locationPath, toPath: imemacan)
//        }
        
        DispatchQueue.main.async {
            self.percentageLabel.text = "安装"
        }
    }
    
    /// 监听下载进度
    ///
    /// - Parameters:
    ///   - session: 当前会话
    ///   - downloadTask: 当前会话任务
    ///   - bytesWritten: 本次写入数据大小
    ///   - totalBytesWritten: 已经写入数据大小
    ///   - totalBytesExpectedToWrite: 要下载的文件总大小
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        //下载进度
        print("total: \(totalBytesExpectedToWrite), current: \(totalBytesWritten)")
        
        /// 百分比
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage
        }
    }
    
}


// MARK: - UIColor Extension
extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(displayP3Red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 86, g: 30, b: 63)
}

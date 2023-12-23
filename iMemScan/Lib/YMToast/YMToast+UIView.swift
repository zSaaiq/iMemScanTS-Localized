//
//  YMToast + UIView.swift
//  iMemScan
//
//  Created by yiming on 2021/7/11.
//

import UIKit

/*
 *  Infix overload method
 */
func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

/*
 *  Toast Config
 */
let YMToastDefaultDuration  =   2.0
let YMToastFadeDuration     =   0.2
let YMToastHorizontalMargin : CGFloat  =   10.0
let YMToastVerticalMargin   : CGFloat  =   10.0

let YMToastPositionDefault  =   "bottom"
let YMToastPositionTop      =   "top"
let YMToastPositionCenter   =   "center"

// activity
let YMToastActivityWidth  :  CGFloat  = 100.0
let YMToastActivityHeight :  CGFloat  = 100.0
let YMToastActivityPositionDefault    = "center"

// image size
let YMToastImageViewWidth :  CGFloat  = 80.0
let YMToastImageViewHeight:  CGFloat  = 80.0

// label setting
let YMToastMaxWidth       :  CGFloat  = 0.8;      // 80% of parent view width
let YMToastMaxHeight      :  CGFloat  = 0.8;
let YMToastFontSize       :  CGFloat  = 16.0
let YMToastMaxTitleLines              = 0
let YMToastMaxMessageLines            = 0

// shadow appearance
let YMToastShadowOpacity  : CGFloat   = 0.8
let YMToastShadowRadius   : CGFloat   = 6.0
let YMToastShadowOffset   : CGSize    = CGSize.init(width: 4.0, height: 4.0)

let YMToastOpacity        : CGFloat   = 0.6
let YMToastCornerRadius   : CGFloat   = 10.0

var YMToastActivityView: UnsafePointer<UIView>?    =   nil
var YMToastTimer: UnsafePointer<Timer>?          =   nil
var YMToastView: UnsafePointer<UIView>?            =   nil

/*
 *  Custom Config
 */
let YMToastHidesOnTap       =   true
let YMToastDisplayShadow    =   true

//YMToast (UIView + Toast using Swift)

extension UIView {
    
    /*
     *  public methods
     */
    func makeToast(message msg: String) {
        self.makeToast(message: msg, duration: YMToastDefaultDuration, position: YMToastPositionCenter as AnyObject)
    }
    
    func makeToast(message msg: String, position: AnyObject) {
        self.makeToast(message: msg, duration: YMToastDefaultDuration, position: position as AnyObject)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg: msg, title: nil, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String) {
        let toast = self.viewForMessage(msg: msg, title: title, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, image: UIImage) {
        let toast = self.viewForMessage(msg: msg, title: nil, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String, image: UIImage) {
        let toast = self.viewForMessage(msg: msg, title: title, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    
    func showToast(toast: UIView) {
        self.showToast(toast: toast, duration: YMToastDefaultDuration, position: YMToastPositionDefault as AnyObject)
    }
    
    func showToast(toast: UIView, duration: Double, position: AnyObject) {
        let existToast = objc_getAssociatedObject(self, &YMToastView) as! UIView?
        if existToast != nil {
            if let timer: Timer = objc_getAssociatedObject(existToast!, &YMToastTimer) as? Timer {
                timer.invalidate();
            }
            self.hideToast(toast: existToast!, force: false);
        }
        
        toast.center = self.centerPointForPosition(position: position, toast: toast)
        toast.alpha = 0.0
        
        if YMToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: Selector(("handleToastTapped:")))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled = true;
            toast.isExclusiveTouch = true;
        }
        
        self.addSubview(toast)
        objc_setAssociatedObject(self, &YMToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        
        UIView.animate(withDuration: YMToastFadeDuration,
                                   delay: 0.0, options: ([.curveEaseOut, .allowUserInteraction]),
                                   animations: {
                                    toast.alpha = 1.0
        },
                                   completion: { (finished: Bool) in
                                    let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.toastTimerDidFinish), userInfo: toast, repeats: false)
                                    objc_setAssociatedObject(toast, &YMToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    func makeToastActivity() {
        self.makeToastActivity(position: YMToastActivityPositionDefault as AnyObject)
    }
    
    func makeToastActivityWithMessage(message msg: String){
        self.makeToastActivity(position: YMToastActivityPositionDefault as AnyObject, message: msg)
    }
    
    func makeToastActivity(position pos: AnyObject, message msg: String = "") {
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &YMToastActivityView) as? UIView
        if existingActivityView != nil { return }
        
        let activityView = UIView(frame: CGRect.init(x: 0, y: 0, width: YMToastActivityWidth, height: YMToastActivityHeight))
        activityView.center = self.centerPointForPosition(position: pos, toast: activityView)
        activityView.backgroundColor = UIColor.black.withAlphaComponent(YMToastOpacity)
        activityView.alpha = 0.0
        activityView.autoresizingMask = ([.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin])
        activityView.layer.cornerRadius = YMToastCornerRadius
        
        if YMToastDisplayShadow {
            activityView.layer.shadowColor = UIColor.black.cgColor
            activityView.layer.shadowOpacity = Float(YMToastShadowOpacity)
            activityView.layer.shadowRadius = YMToastShadowRadius
            activityView.layer.shadowOffset = YMToastShadowOffset
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .white
        activityIndicatorView.center = CGPoint.init(x: activityView.bounds.size.width / 2, y: activityView.bounds.size.height / 2)
        activityView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        if (!msg.isEmpty){
            activityIndicatorView.frame.origin.y -= 10
            let activityMessageLabel = UILabel(frame: CGRect.init(x: activityView.bounds.origin.x, y: (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), width: activityView.bounds.size.width, height: 20))
            activityMessageLabel.textColor = UIColor.white
            //activityMessageLabel.font = (msg.characters.count<=10) ? UIFont(name:activityMessageLabel.font.fontName, size: 16) : UIFont(name:activityMessageLabel.font.fontName, size: 13)
            activityMessageLabel.textAlignment = .center
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)
        }
        
        self.addSubview(activityView)
        
        // associate activity view with self
        objc_setAssociatedObject(self, &YMToastActivityView, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        UIView.animate(withDuration: YMToastFadeDuration,
                                   delay: 0.0,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: {
                                    activityView.alpha = 1.0
        },
                                   completion: nil)
    }
    
    func hideToastActivity() {
        let existingActivityView = objc_getAssociatedObject(self, &YMToastActivityView) as! UIView?
        if existingActivityView == nil { return }
        UIView.animate(withDuration: YMToastFadeDuration,
                                   delay: 0.0,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: {
                                    existingActivityView!.alpha = 0.0
        },
                                   completion: { (finished: Bool) in
                                    existingActivityView!.removeFromSuperview()
                                    objc_setAssociatedObject(self, &YMToastActivityView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    /*
     *  private methods (helper)
     */
    func hideToast(toast: UIView) {
        self.hideToast(toast: toast, force: false);
    }
    
    func hideToast(toast: UIView, force: Bool) {
        let completeClosure = { (finish: Bool) -> () in
            toast.removeFromSuperview()
            objc_setAssociatedObject(self, &YMToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force {
            completeClosure(true)
        } else {
            UIView.animate(withDuration: YMToastFadeDuration,
                                       delay: 0.0,
                                       options: ([.curveEaseIn, .beginFromCurrentState]),
                                       animations: {
                                        toast.alpha = 0.0
            },
                                       completion:completeClosure)
        }
    }
    
    @objc func toastTimerDidFinish(timer: Timer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }
    
    func handleToastTapped(recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &YMToastTimer) as! Timer
        timer.invalidate()
        
        self.hideToast(toast: recognizer.view!)
    }
    
    func centerPointForPosition(position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize  = self.bounds.size
            if position.lowercased == YMToastPositionTop {
                return CGPoint.init(x: viewSize.width/2, y: toastSize.height/2 + YMToastVerticalMargin)
            } else if position.lowercased == YMToastPositionDefault {
                return CGPoint.init(x: viewSize.width/2, y: viewSize.height - toastSize.height/2 - YMToastVerticalMargin)
            } else if position.lowercased == YMToastPositionCenter {
                return CGPoint.init(x: viewSize.width/2, y: viewSize.height/2)
            }
        } else if position is NSValue {
            return position.cgPointValue
        }
        
        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(position: YMToastPositionDefault as AnyObject, toast: toast)
    }
    
    func viewForMessage(msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil { return nil }
        
        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        let wrapperView = UIView()
        wrapperView.autoresizingMask = ([.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin])
        wrapperView.layer.cornerRadius = YMToastCornerRadius
        wrapperView.backgroundColor = UIColor.black.withAlphaComponent(YMToastOpacity)
        
        let isDark = traitCollection.userInterfaceStyle == .dark
        if isDark {
            wrapperView.backgroundColor = UIColor.white.withAlphaComponent(YMToastOpacity)
        } else {
            wrapperView.backgroundColor = UIColor.black.withAlphaComponent(YMToastOpacity)
        }
        
        if YMToastDisplayShadow {
            wrapperView.layer.shadowColor = UIColor.black.cgColor
            wrapperView.layer.shadowOpacity = Float(YMToastShadowOpacity)
            wrapperView.layer.shadowRadius = YMToastShadowRadius
            wrapperView.layer.shadowOffset = YMToastShadowOffset
        }
        
        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .scaleAspectFit

            imageView!.frame = CGRect.init(x: YMToastHorizontalMargin, y: YMToastVerticalMargin, width: (image?.size.width)!, height: (image?.size.height)!)
        }
        
        var imageWidth: CGFloat, imageHeight: CGFloat, imageLeft: CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            imageLeft = YMToastHorizontalMargin
        } else {
            imageWidth  = 0.0; imageHeight = 0.0; imageLeft   = 0.0
        }
        
        let maxWidth = imageView != nil ? self.bounds.width - (imageView?.frame.origin.x)! - (imageView?.frame.size.width)! - YMToastHorizontalMargin - YMToastHorizontalMargin*2 : self.bounds.width - YMToastHorizontalMargin * 2-YMToastHorizontalMargin*2;
        
        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = YMToastMaxTitleLines
            titleLabel!.font = UIFont.boldSystemFont(ofSize: YMToastFontSize)
            titleLabel!.textAlignment = .center
            titleLabel!.lineBreakMode = .byWordWrapping
            titleLabel!.textColor = UIColor.white
            titleLabel!.backgroundColor = UIColor.clear
            titleLabel!.alpha = 1.0
            titleLabel!.text = title
            
            var titSize = titleLabel?.sizeThatFits(CGSize.init(width: 0, height: 20))
            let titWidth = (titSize?.width)! > maxWidth ? maxWidth : titSize?.width;
            titSize = titleLabel?.sizeThatFits(CGSize.init(width: titWidth!, height: 0))
            
            titleLabel!.frame = CGRect.init(x: 0.0, y: 0.0, width: titWidth!, height: (titSize?.height)!)
        }
        
        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = YMToastMaxMessageLines
            msgLabel!.font = UIFont.systemFont(ofSize: YMToastFontSize)
            msgLabel!.lineBreakMode = .byWordWrapping
            msgLabel!.textAlignment = .center
            msgLabel!.textColor = UIColor.white
            
            let isDark = traitCollection.userInterfaceStyle == .dark
            if isDark {
                msgLabel!.textColor = UIColor.gray
            } else {
                msgLabel!.textColor = UIColor.white
            }
            
            msgLabel!.backgroundColor = UIColor.clear
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg
            
            var msgSize = msgLabel?.sizeThatFits(CGSize.init(width: 0, height: 20))
            let msgWidth = (msgSize?.width)! > maxWidth ? maxWidth : msgSize?.width;
            msgSize = msgLabel?.sizeThatFits(CGSize.init(width: msgWidth!, height: 0))
            
            msgLabel!.frame = CGRect.init(x: 0.0, y: 0.0, width: msgWidth!, height: (msgSize?.height)!)
        }
        
        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = YMToastVerticalMargin
            titleLeft = imageLeft + imageWidth + YMToastHorizontalMargin
        } else {
            titleWidth = 0.0; titleHeight = 0.0; titleTop = 0.0; titleLeft = 0.0
        }
        
        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + YMToastVerticalMargin
            msgLeft = imageLeft + imageWidth + YMToastHorizontalMargin
        } else {
            msgWidth = 0.0; msgHeight = 0.0; msgTop = 0.0; msgLeft = 0.0
        }
        
        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft  = max(titleLeft, msgLeft)
        
        // set wrapper view's frame
        let wrapperWidth  = max(imageWidth + YMToastHorizontalMargin * 2, largerLeft + largerWidth + YMToastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + YMToastVerticalMargin, imageHeight + YMToastVerticalMargin * 2)
        wrapperView.frame = CGRect.init(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        
        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect.init(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        if msgLabel != nil {
            msgLabel!.frame = CGRect.init(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        if imageView != nil {
            imageView?.frame.origin.y = (wrapperView.frame.size.height - (imageView?.frame.size.height)!)/2
            wrapperView.addSubview(imageView!)
        }
        
        return wrapperView
    }
    
}



//
//  PokerInputView.swift
//  PokerCard
//
//  Created by Weslie on 2019/9/16.
//  Copyright © 2019 Weslie (https://www.iweslie.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

/// Base Poker Input View with several style
public class PokerInputView: PokerAlertView {
    
    var Field:String = ""
    var Holder:String = ""
    
    
    public enum Style {
        case `default`
        case promotion
    }
    
    /// input text closure
    internal var inputText: ((_ text: String) -> Void)!
    /// input validation closure
    internal var validation: ((_ text: String) -> Bool)?
    
    /// input Text Field on the `PokerInputView`
    public var inputTextField: UITextField! {
        didSet {
            inputTextField.addTarget(self, action: #selector(removeInputBorder), for: .editingChanged)
        }
    }
    
    internal var inputContainerViewHeight: CGFloat = 36
    internal var inputContainerView = PKContainerView()
    
    // promotion style
    lazy var promotionContainerView: UIView = {
        let containerView = PKContainerView()
        return containerView
    }()
    lazy var promotionLeftMarginView: UIView = {
        let leftMargin = UIView()
        leftMargin.backgroundColor = PKColor.pink
        leftMargin.translatesAutoresizingMaskIntoConstraints = false
        return leftMargin
    }()
    
    internal var promotionLabel: UILabel?
    
    convenience init(title: String,
                     detail: String? = nil,
                     field: String? = nil,
                     holder: String? = nil,
                     style: PokerStyle? = .primary) {
        self.init(title: title, detail: detail)
        
        self.Field = field!
        self.Holder = holder!
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        setupInputView()
    }
    
    convenience init(title: String, promotion: String? = nil, secondary: String? = nil, style: PokerStyle = .default) {
        self.init(title: title, detail: secondary)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        setupPromotion(with: promotion, style: style)
        setupPromotionInputView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupInputView() {
        inputContainerViewHeight = 36
        inputContainerView.layer.cornerRadius = 8
        insertSubview(inputContainerView, at: 0)
        
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.topAnchor.constraint(equalTo: (detailLabel ?? promotionLabel ?? titleLabel).bottomAnchor, constant: lineSpacing).isActive = true
        inputContainerView.constraint(withLeadingTrailing: titleSpacing)
        inputContainerView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -lineSpacing).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: inputContainerViewHeight).isActive = true
        
        let lineView = UIView()
        lineView.backgroundColor = PKColor.seperator
        lineView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.addSubview(lineView)
        lineView.constraint(withLeadingTrailing: 0)
        lineView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputTextField = PKTextField(fontSize: 18)
        inputTextField.text = Field
        inputTextField.placeholder = Holder
        inputTextField.clearButtonMode = .whileEditing
        inputContainerView.addSubview(inputTextField)
        inputTextField.constraint(withLeadingTrailing: 0)
        inputTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: lineView.topAnchor).isActive = true
    }
    
    private func setupPromotionInputView() {
        inputContainerViewHeight = 48
        
        inputContainerView = PokerSubView()
        addSubview(inputContainerView)
        
        let spacing = detailLabel == nil ? titleSpacing : lineSpacing
        inputContainerView.topAnchor.constraint(equalTo: (detailLabel ?? promotionLabel ?? titleLabel).bottomAnchor, constant: spacing).isActive = true
        inputContainerView.constraint(withLeadingTrailing: titleSpacing)
        inputContainerView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -titleSpacing).isActive = true
        inputContainerView.heightAnchor.constraint(equalToConstant: inputContainerViewHeight).isActive = true
        
        inputTextField = PKTextField(fontSize: 25)
        inputContainerView.addSubview(inputTextField)
        inputTextField.constraint(withLeadingTrailing: 0)
        inputTextField.constraint(withTopBottom: 0)
    }
    
    private func setupPromotion(with promotionText: String?, style: PokerStyle) {
        guard let promotion = promotionText else { return }
        
        titleBDetailTCons?.isActive = false
        
        detailLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        
        let promotionLabel = PKLabel(fontSize: 14)
        promotionLabel.text = promotion
        promotionLabel.textAlignment = .natural
        self.promotionLabel = promotionLabel
        addSubview(promotionLabel)
        
        promotionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        promotionLabel.bottomAnchor.constraint(equalTo: (detailLabel ?? inputContainerView).topAnchor, constant: -12).isActive = true
        promotionLabel.constraint(withLeadingTrailing: 20)
        
        insertSubview(promotionContainerView, belowSubview: promotionLabel)
        promotionContainerView.backgroundColor = PKColor.pink.withAlphaComponent(0.1)
        promotionContainerView.topAnchor.constraint(equalTo: promotionLabel.topAnchor, constant: -4).isActive = true
        promotionContainerView.bottomAnchor.constraint(equalTo: promotionLabel.bottomAnchor, constant: 4).isActive = true
        promotionContainerView.leadingAnchor.constraint(equalTo: promotionLabel.leadingAnchor, constant: -8).isActive = true
        promotionContainerView.trailingAnchor.constraint(equalTo: promotionLabel.trailingAnchor, constant: 5).isActive = true
        
        promotionContainerView.addSubview(promotionLeftMarginView)
        promotionLeftMarginView.leadingAnchor.constraint(equalTo: promotionContainerView.leadingAnchor).isActive = true
        promotionLeftMarginView.constraint(withTopBottom: 0)
        promotionLeftMarginView.widthAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    internal func shakeInputView() {
        inputContainerView.layer.borderColor = PKColor.red.cgColor
        inputContainerView.layer.borderWidth = 1
        let shake = CAKeyframeAnimation(keyPath: "position.x")
        shake.values = [0, -5, 5, -5, 0]
        shake.duration = 0.25
        shake.isAdditive = true
        inputContainerView.layer.add(shake, forKey: nil)
        
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
    
    @objc internal func removeInputBorder() {
        inputContainerView.layer.removeAllAnimations()
        inputContainerView.layer.borderWidth = 0
    }
    
    @objc
    private func onKeyboardShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curveIntValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int else { return }
        
        let animationCurve = UIView.AnimationCurve(rawValue: curveIntValue) ?? .linear
        let animationOptions = UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue << 16))
        
        // move up input view from covering by keyboard
        UIView.animate(withDuration: duration, delay: 0, options: animationOptions, animations: {
            let popupFrameY = self.frame.origin.y
            let popupHeight = self.frame.height
            
            // if popup bottom + 15 > keyboard top, then move up
            if popupFrameY + popupHeight + 15 > keyboardFrame.origin.y {
                self.frame.origin.y = keyboardFrame.origin.y - popupHeight - 30
            }
        }, completion: nil)
    }
    
}

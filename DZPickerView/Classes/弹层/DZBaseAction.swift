//
//  DZBaseAction.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/7.
//

import UIKit

enum DZBaseActionStyle: Int {
    case action = 0
    case alert = 1
}

public class DZBaseAction: UIViewController {
    private var didShowBlock: (()->())?
    private let tap = UITapGestureRecognizer.init()
    private lazy var mainWindow: UIWindow? = {
        guard let mainWindow = UIApplication.shared.delegate?.window else {
            return nil
        }
        return mainWindow
    }()
    
    let animateDuration: TimeInterval = 0.3
    var style = DZBaseActionStyle.init(rawValue: 0)
    
    lazy var contentWindow: UIWindow = {
        let contentWindow = UIWindow.init(frame: UIScreen.main.bounds)
        contentWindow.windowLevel = UIWindow.Level.normal
        contentWindow.backgroundColor = UIColor.clear
        contentWindow.rootViewController = self
        return contentWindow
    }()
    
    lazy var backgroundView: UIView = {
        let backgroundView = UIView.init(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        backgroundView.alpha = 0
        self.view.addSubview(backgroundView)
        self.view.sendSubviewToBack(backgroundView)
        
        tap.addTarget(self, action: #selector(onTapBackgroundView))
        tap.numberOfTapsRequired = 1
        backgroundView.isUserInteractionEnabled = true
        backgroundView.isMultipleTouchEnabled = false
        backgroundView.addGestureRecognizer(tap)
        
        return backgroundView
    }()
    
    lazy var showContentView: DZBaseActionContentView = {
        let showContentView = DZBaseActionContentView.init(frame: CGRect.init(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: 0))
        showContentView.backgroundColor = UIColor.clear
        self.view.addSubview(showContentView)
        self.view.bringSubviewToFront(showContentView)
        return showContentView
    }()
    
    func setTapToDismissEnabled(enabled: Bool) {
        self.tap.isEnabled = enabled
    }
    
    // MARK: - show
    func show() {
        self.contentWindow.makeKeyAndVisible()
        self.showBackgroundView()
        self.showAnimation()
    }
    
    func show(completion:@escaping ()->()) {
        self.didShowBlock = completion
        self.show()
    }
    
    func showBackgroundView() {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 {
            self.mainWindow?.tintAdjustmentMode = .dimmed
            self.mainWindow?.tintColorDidChange()
        }
        
        UIView.animate(withDuration: animateDuration) {
            self.backgroundView.alpha = 1
        } completion: { finished in
            guard finished == true else {
                return
            }
            self.didShowBlock?()
        }
    }
    
    func showAnimation() {
        switch style {
        case .alert:
            self.showAnimationForAlert()
        default:
            self.showAnimationForAction()
        }
    }
    
    func showAnimationForAction() {
        var frame = self.showContentView.frame
        self.showContentView.frame = CGRect.init(origin: CGPoint.init(x: frame.origin.x, y: self.contentWindow.bounds.size.height), size: frame.size)
        let y = self.contentWindow.bounds.size.height - frame.size.height
        frame = CGRect.init(origin: CGPoint.init(x: frame.origin.x, y: y), size: frame.size)
        
        UIView.animate(withDuration: animateDuration) {
            self.showContentView.frame = frame
        }
    }
    
    func showAnimationForAlert() {
        let frame = self.showContentView.frame
        let y = (self.view.bounds.size.height - frame.size.height) * 0.5
        self.showContentView.frame = CGRect.init(origin: CGPoint.init(x: frame.origin.x, y: y), size: frame.size)
        
        let animation = CAKeyframeAnimation.init(keyPath: "transform")
        animation.values = [NSValue.init(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
                            NSValue.init(caTransform3D: CATransform3DMakeScale(1.05, 1.05, 1)),
                            NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1))]
        animation.keyTimes = [0, 0.5, 1]
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.duration = animateDuration
        self.showContentView.layer.add(animation, forKey: "showAlert")
    }
    
    // MARK: - dismiss
    func dismiss() {
        self.dismiss(sender: nil)
    }
    
    func dismiss(sender: AnyObject?) {
        self.dismiss(sender: sender, animated: true)
    }
    
    func dismiss(sender: AnyObject?, animated: Bool) {
        if NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 {
            self.mainWindow?.tintAdjustmentMode = .automatic
            self.mainWindow?.tintColorDidChange()
        }
        
        switch style {
        case .alert:
            self.dismissAnimationForAlert(animated: animated)
        default:
            self.dismissAnimationForAction(animated: animated)
        }
    }
    
    func dismissAnimationForAction(animated: Bool) {
        let frame = self.showContentView.frame
        let y = self.contentWindow.bounds.size.height
        let newFrame = CGRect.init(origin: CGPoint.init(x: frame.origin.x, y: y), size: frame.size)
        
        UIView.animate(withDuration: animateDuration) {
            self.showContentView.frame = newFrame
            self.backgroundView.alpha = 0
        } completion: { finished in
            self.contentWindow.isHidden = true
            self.contentWindow.removeFromSuperview()
            self.contentWindow.rootViewController = nil
            self.mainWindow?.makeKeyAndVisible()
        }
    }
    
    func dismissAnimationForAlert(animated: Bool) {
        if animated {
            let animation = CAKeyframeAnimation.init(keyPath: "transform")
            animation.values = [NSValue.init(caTransform3D: CATransform3DMakeScale(1.0, 1.0, 1)),
                                NSValue.init(caTransform3D: CATransform3DMakeScale(0.95, 0.95, 1)),
                                NSValue.init(caTransform3D: CATransform3DMakeScale(0.8, 0.8, 1))]
            animation.keyTimes = [0, 0.5, 1]
            animation.isRemovedOnCompletion = false
            animation.duration = animateDuration
            self.showContentView.layer.add(animation, forKey: "dismissAlert")
        }
        
        UIView.animate(withDuration: animated ? animateDuration : 0) {
            self.backgroundView.alpha = 0
            self.contentWindow.isHidden = true
            self.contentWindow.removeFromSuperview()
            self.contentWindow.rootViewController = nil
        } completion: { finished in
            self.mainWindow?.makeKeyAndVisible()
        }

    }

    // MARK: - selectoer
    @objc func onTapBackgroundView() {
        self.dismiss()
    }
}

class DZBaseActionContentView: UIView {
    func addSubview(view: UIView) {
        super.addSubview(view)
        self.sizeToFit()
    }
    
    func contentViewSizeToFit() {
        guard let lastObjectHeight = self.subviews.last?.frame.maxY else {
            return
        }
        
        guard let superView = self.superview else {
            return
        }
        
        self.frame = CGRect.init(x: 0, y: superView.frame.size.height - lastObjectHeight, width: superView.frame.size.width, height: lastObjectHeight)
    }
}

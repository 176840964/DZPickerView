//
//  DZActionContainer.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/4.
//

import UIKit

public func viewSafeAreaInset(view: UIView?) -> UIEdgeInsets {
    if #available(iOS 11.0, *) {
        return view?.safeAreaInsets ?? UIEdgeInsets.zero
    }
    return UIEdgeInsets.zero;
}

public let windowBottomSafeAreaHeight = viewSafeAreaInset(view: UIApplication.shared.keyWindow).bottom

@objc public class DZActionContainer: DZBaseAction {
    /// 创建并展示
    /// - Parameters:
    ///   - title: 标题
    ///   - contextVC: 外部传入的内容区
    ///   - height: 弹窗的总高度
    ///   - cancelHandle: 取消回调
    /// - Returns: 返回实例对象
    @discardableResult
    @objc public class func createAndShow(title: String, contextVC: UIViewController, height: Float = 280, cancelHandle: @escaping (()->()) = { }) -> DZActionContainer {
        let vc = DZActionContainer()
        vc.titleStr = title
        vc.totalHeight = height
        vc.contextVC = contextVC
        vc.cancelHandle = cancelHandle
        DispatchQueue.main.async {
            vc.show()            
        }
        return vc
    }
    
    @objc public override func show() {
        super.show()
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform.init(translationX: 0, y: CGFloat(-self.totalHeight))
        }
    }
    
    @objc public override func dismiss() {
        super.dismiss()
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = CGAffineTransform.identity
        }
        cancelHandle?()
    }
    
    @objc public var cancelHandle: (()->())?
    @objc public var contextVC = UIViewController()
    
    @objc public var titleStr: String? {
        didSet {
            self.titleLab.text = titleStr
        }
    }
    
    private var _totalHeight: Float = 280
    @objc public var totalHeight: Float {
        set {
            _totalHeight = newValue
        }
        get {
            let min = 280
            let max = Int(UIScreen.main.bounds.height - 150)
            if 0..<min ~= Int(_totalHeight) {
                return Float(min)
            } else if min...max ~= Int(_totalHeight) {
                return _totalHeight
            } else {
                return Float(max)
            }
        }
    }
    
    // MARK: - private
    private let containerView = UIView()
    private let headerBgView = UIView()
    private let titleLab = UILabel()
    private let closeBtn = UIButton()

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupContraints()
    }
    
    private func setupUI() {
        self.containerView.backgroundColor = UIColor.white
        self.view.addSubview(self.containerView)
        
        self.headerBgView.backgroundColor = UIColor.white
        self.containerView.addSubview(self.headerBgView)
        
        self.titleLab.textAlignment = .center
        self.titleLab.textColor = UIColor.darkGray
        self.titleLab.font = UIFont.systemFont(ofSize: 16)
        headerBgView.addSubview(self.titleLab)
        
        self.closeBtn.contentEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        self.closeBtn.addTarget(self, action: #selector(onTapCloseBtn(btn:)), for: .touchUpInside)
        headerBgView.addSubview(self.closeBtn)
        
        self.addChild(contextVC)
        self.containerView.insertSubview(contextVC.view, belowSubview: headerBgView)
    }
    
    private func setupContraints() {
        self.containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp_bottom)
            make.height.equalTo(self.totalHeight + Float(windowBottomSafeAreaHeight))
        }
        
        headerBgView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(62)
        }
        
        self.closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(38)
            make.right.equalToSuperview().offset(-6)
            make.top.equalToSuperview().offset(12)
        }
        
        self.titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.height.equalTo(22)
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
        }
        
        contextVC.view.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.titleLab.snp_bottom).offset(20)
            make.bottom.equalToSuperview().offset(-30 - windowBottomSafeAreaHeight)
        }
    }
    
    // MARK: - selectoer
    @objc func onTapCloseBtn(btn: UIButton) {
        dismiss()
    }

}

//
//  DZPickerAction.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/4.
//

import UIKit

@objc public class DZPickerAction: DZActionContainer {
    // MARK: - public
    @discardableResult
    /// 创建并展示
    /// - Parameters:
    ///   - defaultIndexArr: 初始值
    ///   - title: 标题
    ///   - height: 高度
    ///   - cols: 列数
    ///   - rows: 行数回调
    ///   - stringForRow: 元素中的标题回调
    ///   - heightForRow: 元素的高度回调
    ///   - selected: 选中回调
    /// - Returns: 返回实例对象
    @objc public class func createAndShow(defaultIndexArr: [Int] = [Int](), title: String, height: Float = 280, cols: Int = 1 , rows: @escaping ((_ col: Int)->Int), stringForRow: @escaping ((_ row: Int, _ componect: Int)->String), heightForRow: @escaping (()->CGFloat) = { return 42 }, selected: @escaping ((_ rows: [Int])->())) -> DZPickerAction {
        let vc = DZPickerAction()
        vc.titleStr = title
        vc.totalHeight = height
        vc.components = cols
        vc.rows = rows
        vc.stringForRow = stringForRow
        vc.heightForRow = heightForRow
        vc.selected = selected
        vc.defaultIndexArr = defaultIndexArr
        DispatchQueue.main.async {
            vc.show()
        }
        return vc
    }
    
    @objc public var defaultIndexArr:[Int] = [Int]()
    @objc public var components: Int = 0
    @objc public var rows: ((_ component: Int)->Int) = { component in return 0 }
    @objc public var stringForRow: ((_ row: Int, _ componect: Int)->String) = { row,componect in return "" }
    @objc public var heightForRow: (()->CGFloat) = { return CGFloat(42) }
    @objc public var selected: ((_ rows: [Int])->()) = {rows in }
    
    // MARK: - private
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let okBtn = UIButton()
        okBtn.layer.cornerRadius = 20
        okBtn.backgroundColor = UIColor.red
        okBtn.setTitle("确定", for: .normal)
        okBtn.setTitleColor(UIColor.white, for: .normal)
        okBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        okBtn.addTarget(self, action: #selector(onTapOk(btn:)), for: .touchUpInside)
        self.contextVC.view.addSubview(okBtn)
        okBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
            make.height.equalTo(40)
        }
        
        let picker = DZPickerView.create(defaultIndexArr: defaultIndexArr, components: components, rows: rows, heightForRow: heightForRow, stringForRow: stringForRow) { row, componect in
            self.defaultIndexArr[componect] = row
        }
        self.contextVC.view.addSubview(picker)
        picker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(okBtn.snp_top).offset(-12)
        }
    }
    
    // MARK: - selector
    @objc func onTapOk(btn: UIButton) {
        self.selected(self.defaultIndexArr)
        self.dismiss()
    }
}

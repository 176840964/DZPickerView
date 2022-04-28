//
//  DZTimePicker.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/8.
//

import UIKit

@objc public class DZTimePickerAction: DZActionContainer {
    // MARK: - public
    /// 创建并展示
    /// - Parameters:
    ///   - title: 标题
    ///   - height: 弹出高度
    ///   - defaultValue: 初始值时间字符串
    ///   - minStep: 分钟间隔步长
    ///   - completion: 完成回调
    ///   - cancelHandle: 取消回调
    /// - Returns: 返回实例对象
    @discardableResult @objc public class func createAndShow(title: String, height: Float, defaultValue: [String], minStep: Int = 1, completion: @escaping ((_ times: [String])->()), cancelHandle: @escaping (()->())) -> DZTimePickerAction {
        let picker = DZTimePickerAction.init()
        picker.mmStep = minStep
        picker.titleStr = title
        picker.totalHeight = height
        picker.cancelHandle = cancelHandle
        picker.completion = completion
        picker.selectTimes = defaultValue
        DispatchQueue.main.async {
            picker.show()            
        }
        return picker
    }
    
    // MARK: - private
    private var mmStep = 1
    private var hhmmArr = [[String]]()
    private var selTime: String = ""
    private var selectTimes = [String]()
    private var completion: ((_ times: [String])->())?
    private var startBtn = UIButton()
    private var endBtn = UIButton()
    private var timePicker = DZPickerView()

    public override func viewDidLoad() {
        super.viewDidLoad()
        prapData()
        setupUI()
    }
    
    func prapData() {
        var hhArr = [String]()
        for index in 0..<24 {
            let hh = String.init(format: "%02d", index)
            hhArr.append(hh)
        }
        hhmmArr.append(hhArr)
        
        var mmArr = [String]()
        var index = 0
        while index < 60 {
            let mm = String.init(format: "%02d", index)
            mmArr.append(mm)
            index += mmStep
        }
        hhmmArr.append(mmArr)
        
        // 校准选中的时间数据
        var times = [String]()
        selectTimes.forEach { str in
            var time = "00:00"
            let subTimeArr = Array(str.split(separator: ":").prefix(2))
            if subTimeArr.count == 2 {
                let hhIndex = hhmmArr[0].firstIndex(where: {$0 == subTimeArr[0]}) ?? 0
                let mmIndex = hhmmArr[1].firstIndex(where: {$0 == subTimeArr[1]}) ?? 0
                time = hhmmArr[0][hhIndex] + ":" + hhmmArr[1][mmIndex]
            }
            times.append(time)
        }
        selectTimes = times
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
        
        let subArr: [String] = Array(self.selectTimes.prefix(2))
        selTime = subArr.first ?? "00:00"
        let defaultIndexArr = self.split(time: selTime)
        timePicker = DZPickerView.create(defaultIndexArr: defaultIndexArr, components: self.hhmmArr.count, separator: ":") { [weak self] component in
            guard let self = self else { return 0}
            return self.hhmmArr[component].count
        } heightForRow: {
            return 42
        } stringForRow: { [weak self] row, componect in
            guard let self = self else { return ""}
            return self.hhmmArr[componect][row]
        } selected: { [weak self] row, componect in
            guard let self = self else { return }
            let strArr: [String] = self.selTime.split(separator: ":").compactMap({"\($0)"})
            var hh = strArr[0]
            var mm = strArr[1]
            if componect == 0 {
                hh = self.hhmmArr[componect][row]
            } else {
                mm = self.hhmmArr[componect][row]
            }
            let title = hh + ":" + mm
            self.selTime = title
            
            if self.selectTimes.count < 2 {
                self.selectTimes[0] = title
                return
            }

            guard self.selectTimes.count > 1 else {
                return
            }
            if self.startBtn.isSelected {
                self.selectTimes[0] = title
                self.startBtn.setTitle(title, for: .normal)
                self.startBtn.setTitle(title, for: .selected)
            } else {
                self.selectTimes[1] = title
                self.endBtn.setTitle(title, for: .normal)
                self.endBtn.setTitle(title, for: .selected)
            }
        }
        self.contextVC.view.addSubview(timePicker)
        timePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.selectTimes.count > 1 ? 74 : 10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(okBtn.snp_top).offset(-12)
        }
        
        if subArr.count > 1 {
            setupHeaderTabView()
            self.startBtn.setTitle(subArr[0], for: .normal)
            self.startBtn.setTitle(subArr[0], for: .selected)
            self.startBtn.isSelected = true
            self.endBtn.setTitle(subArr[1], for: .normal)
            self.endBtn.setTitle(subArr[1], for: .selected)
        }
    }
    
    func setupHeaderTabView() {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.white
        headerView.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOpacity = 0.08
        self.contextVC.view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(74)
        }
        
        let space = (UIScreen.main.bounds.width - 100 * 2 - 20) / 4
        
        let startBtn = UIButton()
        startBtn.layer.cornerRadius = 4
        startBtn.backgroundColor = UIColor.clear
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        startBtn.setTitleColor(UIColor.lightGray, for: .normal)
        startBtn.setTitleColor(UIColor.darkGray, for: .selected)
        startBtn.addTarget(self, action: #selector(onTapHeader(btn:)), for: .touchUpInside)
        headerView.addSubview(startBtn)
        startBtn.snp.makeConstraints { make in
            make.left.equalTo(space)
            make.bottom.equalTo(-16)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        self.startBtn = startBtn
        
        let startLab = UILabel()
        startLab.font = UIFont.systemFont(ofSize: 14)
        startLab.text = "开始时间"
        startLab.textAlignment = .center
        startLab.textColor = UIColor.darkGray
        headerView.addSubview(startLab)
        startLab.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.bottom.equalTo(startBtn.snp.top).offset(-8)
            make.centerX.equalTo(startBtn.snp.centerX)
        }
        
        let endBtn = UIButton()
        endBtn.layer.cornerRadius = 4
        endBtn.backgroundColor = UIColor.clear
        endBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        endBtn.setTitleColor(UIColor.lightGray, for: .normal)
        endBtn.setTitleColor(UIColor.darkGray, for: .selected)
        endBtn.addTarget(self, action: #selector(onTapHeader(btn:)), for: .touchUpInside)
        headerView.addSubview(endBtn)
        endBtn.snp.makeConstraints { make in
            make.right.equalTo(-space)
            make.bottom.equalTo(-16)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        self.endBtn = endBtn
        
        let endLab = UILabel()
        endLab.font = UIFont.systemFont(ofSize: 14)
        endLab.text = "截止时间"
        endLab.textAlignment = .center
        endLab.textColor = UIColor.darkGray
        headerView.addSubview(endLab)
        endLab.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.bottom.equalTo(endBtn.snp.top).offset(-8)
            make.centerX.equalTo(endBtn.snp.centerX)
        }   
    }
    
    func split(time: String) -> [Int] {
        var arr = [0, 0]
        let subTimeArr = Array(time.split(separator: ":").prefix(2))
        if subTimeArr.count == 2 {
            arr[0] = hhmmArr[0].firstIndex(where: {$0 == subTimeArr[0]}) ?? 0
            arr[1] = hhmmArr[1].firstIndex(where: {$0 == subTimeArr[1]}) ?? 0
        }
        
        return arr
    }
    
    // MARK: - selector
    @objc func onTapOk(btn: UIButton) {
        self.completion?(self.selectTimes)
        self.dismiss()
    }
    
    @objc func onTapHeader(btn: UIButton) {
        if btn == self.startBtn {
            startBtn.isSelected = true
            endBtn.isSelected = false
        } else {
            startBtn.isSelected = false
            endBtn.isSelected = true
        }
        
        guard let text = btn.titleLabel?.text else {
            return
        }
        selTime = text
        let arr = self.split(time: text)
        timePicker.selIndexArr = arr
        timePicker.reloadData()
    }
}

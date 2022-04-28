//
//  DZDatePickerAction.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/9.
//

import UIKit
import SnapKit

let sMinYear: Int = 1900
let sMaxYear: Int = 2100

@objc public class DZDatePickerAction: DZActionContainer {
    // MARK: - public
    /// 创建并展示
    /// - Parameters:
    ///   - title: 标题
    ///   - height: 高度
    ///   - minDate: 最小日期
    ///   - maxDate: 最大日期
    ///   - defaultValue: 默认选中日期数组
    ///   - completion: 完成回调
    ///   - cancelHandle: 取消回调
    /// - Returns: 返回实例对象
    @discardableResult @objc public class func createAndShow(title: String, height: Float, minDate: Date, maxDate: Date, defaultValue: [Date], completion: @escaping ((_ dates: [String])->()), cancelHandle: @escaping (()->())) -> DZDatePickerAction? {
        guard minDate < maxDate else {
            print("最小可选日期不能大于最大可选日期")
            return nil
        }
        
        let picker = DZDatePickerAction.init()
        picker.titleStr = title
        picker.totalHeight = height
        picker.cancelHandle = cancelHandle
        picker.selectDates = defaultValue
        picker.minDate = minDate
        picker.maxDate = maxDate
        picker.completion = completion
        DispatchQueue.main.async {
            picker.show()
        }
        return picker
    }

    // MARK: - private
    private var completion: ((_ dates: [String])->())?
    private var minDate = Date()
    private var maxDate = Date()
    private var selDate = Date()
    private var selectDates = [Date]()
    private var datePicker = DZPickerView()
    private var startBtn = UIButton()
    private var endBtn = UIButton()
    private var headerLine = UIView()
    
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
        
        let subArr: [Date] = Array(selectDates.prefix(2))
        selDate = subArr.first ?? Date()
        let defaultArr = indexs(date: selDate)
        datePicker = DZPickerView.create(defaultIndexArr: defaultArr, components: 3, separator: "") { [weak self] component in
            guard let self = self else { return 0 }
            return self.count(component: component)
        } heightForRow: {
            return 42
        } stringForRow: { [weak self] row, componect in
            guard let self = self else { return ""}
            return self.itemTitleString(row: row, componect: componect)
        } selected: { [weak self] (row, componect) in
            guard let self = self else { return }
            self.selectedItem(row: row, componect: componect)
        }
        self.contextVC.view.addSubview(datePicker)
        datePicker.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.selectDates.count > 1 ? 74 : 10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(okBtn.snp_top).offset(-12)
        }
        
        if selectDates.count > 1 {
            setupHeaderTabView()
            self.startBtn.setTitle(selectDates[0].dzString(dateFormat: "yyyy.MM.dd", timeZone: .current), for: .normal)
            self.startBtn.setTitle(selectDates[0].dzString(dateFormat: "yyyy.MM.dd", timeZone: .current), for: .selected)
            self.startBtn.isSelected = true
            self.endBtn.setTitle(selectDates[1].dzString(dateFormat: "yyyy.MM.dd", timeZone: .current), for: .normal)
            self.endBtn.setTitle(selectDates[1].dzString(dateFormat: "yyyy.MM.dd", timeZone: .current), for: .selected)
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
        startLab.text = "开始日期"
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
        endLab.text = "截止日期"
        endLab.textAlignment = .center
        endLab.textColor = UIColor.darkGray
        headerView.addSubview(endLab)
        endLab.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(100)
            make.bottom.equalTo(endBtn.snp.top).offset(-8)
            make.centerX.equalTo(endBtn.snp.centerX)
        }
        
        headerLine.backgroundColor = UIColor.clear
        headerView.addSubview(headerLine)
        headerLine.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(startBtn.snp_centerY)
            make.width.equalTo(20)
            make.height.equalTo(1)
        }
    }
    
    /// 获取指定列下的行数量
    /// - Parameter component: 列
    /// - Returns: 行数量
    func count(component: Int) -> Int {
        switch component {
        case 0: // 年
            return (self.maxDate.year ?? sMaxYear) - (self.minDate.year ?? sMinYear) + 1
        case 1: // 月
            if self.maxDate.year == self.minDate.year { // 年相等
                return (self.maxDate.month ?? 0) - (self.minDate.month ?? 0) + 1
            } else if self.selDate.year == self.minDate.year { // 选中的年 == 最小年
                return 12 - (self.minDate.month ?? -1) + 1
            } else if self.selDate.year == self.maxDate.year { // 选中的年 == 最大年
                return self.maxDate.month ?? 12
            } else {
                return 12
            }
        case 2: // 日
            var days = 0
            let month = self.selDate.month ?? 0
            switch (month) {
            case 1,3,5,7,8,10,12:
                days = 31
            case 4,6,9,11:
                days = 30
            case 2:
                days = self.selDate.isLeapYear ? 29: 28
            default:
                break;
            }
            
            if self.selDate.year == self.minDate.year
                && self.selDate.month == self.minDate.month {
                return days - self.minDate.day! + 1
            } else if self.selDate.year == self.maxDate.year
                && self.selDate.month == self.maxDate.month {
                return self.maxDate.day ?? days
            } else {
                return days
            }
        default:
            return 0
        }
    }
    
    /// 日期转换下标
    /// - Parameter date: 日期
    /// - Returns: 下标数组
    func indexs(date: Date) -> [Int] {
        let yearIndex = date.year! - minDate.year!
        
        var minMonth = 1
        if minDate.year == maxDate.year {
            minMonth = minDate.month!
        } else if date.year == minDate.year {
            minMonth = minDate.month!
        }
        let monthIndex = date.month! - minMonth
        
        var minDay = 1
        if date.year == minDate.year && date.month == minDate.month {
            minDay = minDate.day!
        }
        let dayIndex = date.day! - minDay
        
        return [yearIndex, monthIndex, dayIndex]
    }
    
    /// 获取显示的文案
    /// - Parameters:
    ///   - row: 行
    ///   - componect: 列
    /// - Returns: 文案
    func itemTitleString(row: Int, componect: Int) -> String {
        switch componect {
        case 0:
            return String((self.minDate.year ?? sMinYear) + row) + "年"
        case 1:
            if self.selDate.year == self.minDate.year {
                return String.init(format: "%02d月", self.minDate.month! + row)
            } else {
                return String.init(format: "%02d月", row + 1)
            }
        case 2:
            if self.selDate.year == self.minDate.year && self.selDate.month == self.minDate.month {
                return String.init(format: "%02d日", self.minDate.day! + row)
            }
            return String.init(format: "%02d日", row + 1)
        default:
            break;
        }
        return ""
    }
    
    func selectedItem(row: Int, componect: Int) {
        let string = self.itemTitleString(row: row, componect: componect)
        var year = self.selDate.year
        var month = self.selDate.month
        var day = self.selDate.day
        switch componect {
        case 0:
            year = string.dzToNSString.integerValue
        case 1:
            month = string.dzToNSString.integerValue
        case 2:
            day = string.dzToNSString.integerValue
        default:
            break;
        }
        
        var date: Date?
        if componect == 0 || componect == 1 { // 转换Date错误的情况，例如：处理2月29日时，修改年的时候 or 3月30日，修改月份为2月的时候
            let dateStr = String.init(format: "%d.%02d.%02d", year!, month!, day!)
            date = dateStr.dzDate(dateFormat: "yyyy.MM.dd", timeZone: .current)
            while (date == nil && day! > 0) {
                day! -= 1
                let dateStr = String.init(format: "%d.%02d.%02d", year!, month!, day!)
                date = dateStr.dzDate(dateFormat: "yyyy.MM.dd", timeZone: .current)
            }
            if day! < 1 {
                date = Date()
            }
        } else {
            let dateStr = String.init(format: "%d.%02d.%02d", year!, month!, day!)
            date = dateStr.dzDate(dateFormat: "yyyy.MM.dd", timeZone: .current)
        }
        
        var d = date ?? Date()
        if d < self.minDate {
            d = self.minDate
        }
        
        if d > self.maxDate {
            d = self.maxDate
        }
        
        self.selDate = d
        self.datePicker.selIndexArr = self.indexs(date: self.selDate)
        self.datePicker.reloadData(component: componect + 1)
        
        if (self.selectDates.count) < 2 {
            self.selectDates[0] = self.selDate
            return
        }
        
        let title = self.selDate.dzString(dateFormat: "yyyy.MM.dd", timeZone: .current)
        if self.startBtn.isSelected {
            self.selectDates[0] = self.selDate
            self.startBtn.setTitle(title, for: .normal)
            self.startBtn.setTitle(title, for: .selected)
        } else {
            self.selectDates[1] = self.selDate
            self.endBtn.setTitle(title, for: .normal)
            self.endBtn.setTitle(title, for: .selected)
        }
    }
    
    @objc func onTapOk(btn: UIButton) {
        if self.selectDates.count > 1 && self.selectDates[0] > self.selectDates[1] {
            print("开始日期不能大于结束日期")
            return
        }
        
        let arr = self.selectDates.map({ $0.dzString(dateFormat: "yyyy.MM.dd", timeZone: .current) })
        self.completion?(arr)
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
        selDate = text.dzDate(dateFormat: "yyyy.MM.dd", timeZone: .current) ?? Date()
        let arr = self.indexs(date: selDate)
        datePicker.selIndexArr = arr
        datePicker.reloadData()
    }
}

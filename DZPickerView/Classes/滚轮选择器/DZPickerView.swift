//
//  DZPickerView.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/7.
//

import UIKit

@objc public class DZPickerView: UIView {
    // MARK: - public
    /// 创建
    /// - Parameters:
    ///   - defaultIndexArr: 初始选中的下标数组
    ///   - components: 组件个数
    ///   - linkage: 组件间是否联动
    ///   - separator: 分隔符
    ///   - rows: 每个组件行数回调
    ///   - heightForRow: 行高度回调
    ///   - stringForRow: 元素title回调
    ///   - selected: 选中回调
    /// - Returns: 返回实例对象
    @objc public class func create(defaultIndexArr:[Int] = [Int](), components: Int = 1, linkage: Bool = false, separator: String = "", rows: @escaping ((_ component: Int)->Int), heightForRow: @escaping (()->CGFloat) = { return 42 }, stringForRow: @escaping ((_ row: Int, _ componect: Int)->String), selected: @escaping ((_ row: Int, _ componect: Int)->())) -> DZPickerView {
        let picker = self.init()
        picker.isLinkage = linkage
        picker.components = components
        picker.rows = rows
        picker.stringForRow = stringForRow
        picker.rowHeight = heightForRow()
        picker.selected = selected
        picker.separator = separator
        picker.selIndexArr = defaultIndexArr
        picker.setupUI()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            if linkage {
                picker.reloadData(component: 0)
            } else {
                picker.reloadData()
            }
        })
        return picker
    }
    
    @objc public var selIndexArr: [Int]? {
        didSet {
            objc_sync_enter(self)
            self.indexPathArr.removeAll()
            selIndexArr?.enumerated().forEach { (index, val) in
                let row = self.rows?(index) ?? 0
                let indexPath = IndexPath.init(row: (val < row ? val : 0), section: 0)
                indexPathArr.append(indexPath)
            }
            objc_sync_exit(self)
        }
    }
    
    /// 指定的起始下标刷新组件，包含当前组件。非联动情况
    /// - Parameter startComponent: 起始下标
    @objc public func reloadData(startComponent: Int = -1) {
        self.pickersArr.enumerated().forEach { index, tableView in
            guard index > startComponent else {
                return
            }
            tableView.reloadData()
            DispatchQueue.main.async {
                self.didSelectRow(tableView: tableView)
            }
        }
    }
    
    /// 刷新指定组件。联动情况
    /// - Parameter component: 组件的下标
    @objc public func reloadData(component: Int) {
        guard component < self.pickersArr.count else { return }
        let tableView = self.pickersArr[component]
        tableView.reloadData()
        // 延时目的：解决联动（日期）情况，会有一些组件不滚动到设定的位置
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.didSelectRow(tableView: tableView)
        })
    }
    
    // MARK: - private
    
    private var isLinkage = false
    private var pickersArr = [UITableView]()
    private var components: Int = 1
    private var rows: ((_ component: Int)->Int)?
    private var rowHeight = 0.0
    private var stringForRow: ((_ row: Int, _ componect: Int)->String)?
    private var selected: ((_ row: Int, _ componect: Int)->())?
    private let centerView = UIView()
    private var separator: String = ""
    
    /// 占位元素个数，列表头部和尾部都会追加emptyItemCount个元素，即tableView的元素个数=emptyItemCount+data.count+emptyItemCount。解决： 内容的高度 < tableView.height时，调用tableView.scrollToRow无效情况
    private var emptyItemCount = 0
    /// 元素不包含emptyItemCount
    private var indexPathArr = [IndexPath]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        guard self.components != 0 else {
            return
        }
        
        let width = CGFloat((Int(UIScreen.main.bounds.width) - 5) / self.components)
        for index in 0..<self.components {
            let tableView = UITableView()
            tableView.backgroundColor = UIColor.clear
            tableView.tag = index
            tableView.dataSource = self
            tableView.delegate = self
            tableView.showsVerticalScrollIndicator = false
            tableView.rowHeight = rowHeight
            tableView.separatorStyle = .none
            tableView.register(DZPickerCell.self, forCellReuseIdentifier: NSStringFromClass(DZPickerCell.self))
            self.addSubview(tableView)
            pickersArr.append(tableView)
            tableView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.width.equalTo(width)
                make.left.equalToSuperview().offset(index * Int(width))
            }
        }
        
        centerView.backgroundColor = UIColor.clear
        centerView.isUserInteractionEnabled = false
        self.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(rowHeight + 1)
        }
        
        let topLine = UIView()
        topLine.isUserInteractionEnabled = false
        topLine.backgroundColor = UIColor.lightGray
        centerView.addSubview(topLine)
        topLine.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        let bottomLine = UIView()
        bottomLine.isUserInteractionEnabled = false
        bottomLine.backgroundColor = UIColor.lightGray
        centerView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        guard self.separator.isEmpty == false else {
            return
        }
        for index in 1..<self.components {
            let lab = UILabel()
            lab.textAlignment = .center
            lab.text = self.separator
            lab.textColor = UIColor.darkGray
            lab.font = UIFont.systemFont(ofSize: 16)
            lab.sizeToFit()
            self.centerView.addSubview(lab)
            lab.snp.makeConstraints { make in
                make.centerX.equalTo(Int(UIScreen.main.bounds.width) / self.components * index)
                make.centerY.equalToSuperview()
                make.size.equalTo(lab.snp_size)
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.pickersArr.forEach { tableView in
            let height = self.bounds.height
            let heightForItem = tableView.rowHeight
            let space = (height - heightForItem) / 2.0
            guard heightForItem != 0 else { return }
            emptyItemCount = Int(space / heightForItem + 1)
        }
    }
}

extension DZPickerView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.rows?(tableView.tag) ?? 0) + emptyItemCount * 2
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(DZPickerCell.self)) as! DZPickerCell
        if emptyItemCount..<((self.rows?(tableView.tag) ?? 0) + emptyItemCount) ~= indexPath.row {
            let str = self.stringForRow?(indexPath.row - emptyItemCount, tableView.tag)
            cell.text = str
            let row = self.indexPathArr[tableView.tag].row
            if indexPath.row == row + emptyItemCount {
                cell.highlight = true
            } else {
                cell.highlight = false
            }
        } else {
            cell.text = ""
            cell.highlight = false
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if emptyItemCount..<((self.rows?(tableView.tag) ?? 0) + emptyItemCount) ~= indexPath.row {
            guard self.indexPathArr[tableView.tag].row != (indexPath.row - emptyItemCount) else {
                return
            }
            self.indexPathArr[tableView.tag] = IndexPath.init(row: indexPath.row - emptyItemCount, section: indexPath.section)
            self.didSelectRow(tableView: tableView)
        }
    }
}

extension DZPickerView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.didSelectRow(tableView: scrollView as! UITableView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {        
            self.didSelectRow(tableView: scrollView as! UITableView)
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let tableView = self.pickersArr.first(where: {$0 == scrollView}) else { return }
        
        let point = scrollView.convert(scrollView.center, from: self)
        tableView.visibleCells.forEach { cell in
            guard let pickerCell = cell as? DZPickerCell else { return }
            let isContains = pickerCell.frame.contains(point)
            pickerCell.highlight = isContains
            guard let indexPath = tableView.indexPath(for: pickerCell), isContains == true else { return }
            self.indexPathArr[tableView.tag] = IndexPath.init(row: indexPath.row - emptyItemCount, section: indexPath.section)
        }
    }
    
    func didSelectRow(tableView: UITableView) {
        let indexPath = self.indexPathArr[tableView.tag]
        var row = indexPath.row
        if row < 0 {
            row = 0
        } else if row > (self.rows?(tableView.tag) ?? 0) - 1 {
            row = (self.rows?(tableView.tag) ?? 0) - 1
        }
        let cellIndexPath = IndexPath.init(row: row + emptyItemCount, section: 0)
        tableView.scrollToRow(at: cellIndexPath, at: UITableView.ScrollPosition.middle, animated: true)
        self.selected?(row, tableView.tag)
    }
}

class DZPickerCell: UITableViewCell {
    var highlight: Bool = false {
        didSet {
            if highlight {
                self.titleLab.textColor = UIColor.darkGray
                self.titleLab.font = UIFont.systemFont(ofSize: 16)
            } else {
                self.titleLab.textColor = UIColor.lightGray
                self.titleLab.font = UIFont.systemFont(ofSize: 16)
            }
        }
    }
    var text: String? {
        didSet {
            self.titleLab.text = text
        }
    }
    
    private let titleLab = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        self.selectionStyle = .none
        
        titleLab.textAlignment = .center
        self.contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.highlight = false
    }
}

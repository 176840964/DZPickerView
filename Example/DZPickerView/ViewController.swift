//
//  ViewController.swift
//  DZPickerView
//
//  Created by DragonetZ on 04/27/2022.
//  Copyright (c) 2022 DragonetZ. All rights reserved.
//

import UIKit
import SnapKit
import DZPickerView

class ViewController: UIViewController {
    let data = ["普通-选择人数", "选择时间", "选择日期"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self))!
        cell.textLabel?.text = self.data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            DZPickerAction.createAndShow(defaultIndexArr: [1, 2], title: "选择人数", height: 348, cols: 2) { col in
                return 10
            } stringForRow: { row, componect in
                return String(format: "%d人", row)
            } heightForRow: {
                return 42
            } selected: { rows in
                print(rows)
            }

        case 1:
            DZTimePickerAction.createAndShow(title: "选择时间", height: 348, defaultValue: ["00:35", "00:55"]) { times in
                print(times)
            } cancelHandle: {
                
            }
            
        case 2:
            let min = "2000.02.18".dzDate()
            let max = "2022.10.20".dzDate()
            let date1 = "2008.02.29".dzDate()
            let date2 = "2011.02.27".dzDate()
            
            DZDatePickerAction.createAndShow(title: "选择日期", height: 442, minDate: min!, maxDate: max!, defaultValue: [date1!, date2!]) { dates in
                print(dates)
            } cancelHandle: {
                
            }
            
        default:
            break
        }
    }
}


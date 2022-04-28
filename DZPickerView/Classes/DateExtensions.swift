//
//  DateExtensions.swift
//  DZPickerView
//
//  Created by DragonetZ on 2022/3/9.
//

import UIKit

public extension Date {
    /// date->string;  default:"yyyy-MM-dd"
    ///
    ///        date.dzString -> "2007-06-29"
    ///        date.dzString(dateFormat: "yyyy-MM-dd HH:mm:ss") -> "2007-06-29 14:23:09"
    ///
    func dzString(dateFormat: String = "yyyy-MM-dd", timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter.string(from: self)
    }
    
    var year: Int? {
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        return calendar.dateComponents(in: .current, from: self).year
    }
    
    var month: Int? {
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        return calendar.dateComponents(in: .current, from: self).month
    }
    
    var day: Int? {
        let calendar = Calendar.init(identifier: Calendar.Identifier.gregorian)
        return calendar.dateComponents(in: .current, from: self).day
    }
    
    var isLeapYear: Bool {
        guard let year = year else { return false }
        return (year % 100 == 0) ? (year % 400 == 0) : (year % 4 == 0)
    }
}

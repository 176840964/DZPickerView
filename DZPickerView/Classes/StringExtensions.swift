//
//  String+Utilities.swift
//  DZPickerView
//
//  Created by DZ on 2021/12/24.
//

import Foundation
import UIKit

// MARK: - base
public extension String {
    /// string -> nsstring
    var dzToNSString: NSString {
        return NSString(string: self)
    }
    
    /// string -> bool
    ///
    ///     "1".dzBool -> true
    ///     "False".dzBool -> false
    ///     "Hello".dzBool = nil
    ///
    var dzBool: Bool? {
        let selfLowercased = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch selfLowercased {
        case "true", "yes", "1":
            return true
        case "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    /// string -> int
    ///
    ///     "101".dzInt -> 101
    ///
    var dzInt: Int? {
        return Int(self)
    }
    
    /// string -> URL
    ///
    ///     "https://google.com".dzUrl -> URL(string: "https://google.com")
    ///     "not url".dzUrl -> nil
    ///
    var dzUrl: URL? {
        return URL(string: self)
    }
    
    /// string -> float
    func dzFloat(locale: Locale = .current) -> Float? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.floatValue
    }
    
    /// string -> double
    func dzDouble(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.doubleValue
    }
    
    /// string -> cgfloat
    func dzCGFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self) as? CGFloat
    }
    
    /// string -> [word]
    ///
    ///     "Swift is amazing".dzWords -> ["Swift", "is", "amazing"]
    var dzWords: [String] {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        return comps.filter { !$0.isEmpty }
    }
    
    /// string中的word count
    ///
    ///     "Swift is amazing".dzWordCount -> 3
    var dzWordCount: Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        let words = comps.filter { !$0.isEmpty }
        return words.count
    }
    
    /// 是否包含指定string
    ///
    ///        "Hello World!".dzContains("O") -> false
    ///        "Hello World!".dzContains("o", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - string: 指定string
    ///   - caseSensitive: 大小写敏感，默认true
    func dzContains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
    
    /// 子串出现次数
    ///
    ///        "Hello World!".dzCount(of: "o") -> 2
    ///        "Hello World!".dzCount(of: "L", caseSensitive: false) -> 3
    ///
    /// - Parameters:
    ///   - string: substring to search for.
    ///   - caseSensitive: set true for case sensitive search (default is true).
    /// - Returns: count of appearance of substring in string.
    func dzCount(of string: String, caseSensitive: Bool = true) -> Int {
        if !caseSensitive {
            return lowercased().components(separatedBy: string.lowercased()).count - 1
        }
        return components(separatedBy: string).count - 1
    }
    
    /// 字符串反转
    @discardableResult mutating func reverse() -> String {
        let chars: [Character] = reversed()
        self = String(chars)
        return self
    }
    
    /// 指定长度随机字符串
    ///
    ///        String.dzRandom(ofLength: 18) -> "u7MMZYvGo9obcOcPj8"
    ///
    /// - Parameter length: number of characters in string.
    /// - Returns: random string of given length.
    static func dzRandom(ofLength length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }
    
    /// 复制到粘贴板
    func dzToPasteboard() {
        UIPasteboard.general.string = self
    }
    
    /// string截取指定长度，并追加指点字符，默认追加"..."
    /// 修改自身值，返回值没有变量接受不会有警告
    ///
    ///        var str = "This is a very long sentence"
    ///        str.dzTruncate(toLength: 14)
    ///        print(str) // prints "This is a very..."
    ///
    /// - Parameters:
    ///   - toLength: maximum number of characters before cutting.
    ///   - trailing: string to add at the end of truncated string (default is "...").
    @discardableResult mutating func dzTruncate(toLength length: Int, trailing: String? = "...") -> String {
        guard length > 0 else { return self }
        if count > length {
            self = self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
        }
        return self
    }
    
    /// string截取指定长度，并追加指点字符，默认追加"..."
    /// 不修改自身值
    ///
    ///        "This is a very long sentence".truncated(toLength: 14) -> "This is a very..."
    ///        "Short sentence".truncated(toLength: 14) -> "Short sentence"
    ///
    /// - Parameters:
    ///   - toLength: maximum number of characters before cutting.
    ///   - trailing: string to add at the end of truncated string.
    /// - Returns: truncated string (this is an extr...).
    func truncated(toLength length: Int, trailing: String? = "...") -> String {
        guard 1..<count ~= length else { return self }
        return self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
    }
}

// MARK: - subscript
public extension String {
    /// 下标获取字符
    ///
    ///        "Hello World!"[3] -> "l"
    ///        "Hello World!"[20] -> nil
    ///
    subscript(index: Int) -> Character? {
        guard index >= 0 && index < self.count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }
    
    /// 半开范围获取子string
    ///
    ///        "Hello World!"[6..<11] -> "World"
    ///        "Hello World!"[21..<110] -> nil
    ///
    subscript(range: CountableRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex..<upperIndex])
    }
    
    /// 封闭范围获取子string
    ///
    ///        "Hello World!"[6...11] -> "World!"
    ///        "Hello World!"[21...110] -> nil
    ///
    /// - Parameter range: Closed range.
    subscript(range: ClosedRange<Int>) -> String? {
        guard let lowerIndex = index(startIndex, offsetBy: max(0, range.lowerBound), limitedBy: endIndex) else { return nil }
        guard let upperIndex = index(lowerIndex, offsetBy: range.upperBound - range.lowerBound, limitedBy: endIndex) else { return nil }
        return String(self[lowerIndex...upperIndex])
    }
    
    /// 第一个字符
    ///
    ///        "Hello".dzFirstCharacter -> Optional("H")
    ///        "".dzFirstCharacter -> nil
    ///
    var dzFirstCharacter: String? {
        guard let firstCharacter = first else { return nil }
        return String(firstCharacter)
    }
    
    /// 最后一个字符
    ///
    ///        "Hello".dzLastCharacter -> Optional("o")
    ///        "".dzLastCharacter -> nil
    ///
    var dzLastCharacter: String? {
        guard let lastCharacter = last else {return nil}
        return String(lastCharacter)
    }
}

// MARK: - sendbox path
public extension String {
    /// document path
    static func dzDocumentDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
    }
    
    /// caches path
    static func dzCachesDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
    }
    
    /// temp path
    static func dzTempDirectory() -> String {
        return NSTemporaryDirectory()
    }
    
    /// library path
    static func dzLibraryDirectory() -> String {
        let cachePath = String.dzCachesDirectory()
        return cachePath.replacingOccurrences(of: "Caches", with: "")
    }
    
    /// document后追加路径
    func dzDocumentPathAppendPath() -> String {
        let documentPath = String.dzDocumentDirectory()
        if self.hasPrefix(documentPath) {
            return self
        } else {
            return documentPath + "/" + self
        }
    }
    
    /// cache后追加路径
    func dzCachePathAppendPath() -> String {
        let cachePath = String.dzCachesDirectory()
        if self.hasPrefix(cachePath) {
            return self
        } else {
            return cachePath + "/" + self
        }
    }
    
    /// tmp后追加路径
    func dzTmpPathAppendPath() -> String {
        let tmpPath = String.dzTempDirectory()
        if self.hasPrefix(tmpPath) {
            return self
        } else {
            return tmpPath + self
        }
    }
    
    /// library后追加路径
    func dzLibraryPathAppendPath() -> String {
        let libraryPath = String.dzLibraryDirectory()
        if self.hasPrefix(libraryPath) {
            return self
        } else {
            return libraryPath + self
        }
    }
    
    func dzCreateDirectory() -> Bool {
        guard FileManager.default.fileExists(atPath: self) else {
            return false
        }
        
        do {
            try FileManager.default.createDirectory(atPath: self, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return false
        }
        
        return true
    }
    
    func dzDirectoryAndFileName() -> (directory: String, fileName: String) {
        let url = URL(fileURLWithPath: self)
        let path = url.deletingLastPathComponent().relativePath
        let file = url.lastPathComponent
        return (path, file)
    }
    
    func dzFileNameList() -> [String]? {
        return try? FileManager.default.contentsOfDirectory(atPath: self)
    }
}

// MARK: - base64
public extension String {
    init?(base64: String) {
        guard let str = base64.dzBase64Decoded() else { return nil }
        self.init(str)
    }
    
    func dzBase64Encoded() -> String? {
        let data = self.data(using: .utf8)
        return data?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func dzBase64Decoded() -> String? {
        guard let data = Data.init(base64Encoded: self, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
            return nil
        }
        return String.init(data: data, encoding: .utf8)
    }
}

// MARK: - verify
public extension String {
    /// 是否包含字母
    ///
    ///        "123abc".dzHasLetters -> true
    ///        "123".dzHasLetters -> false
    ///
    var dzHasLetters: Bool {
        return rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
    }

    /// 是否包含数字
    ///
    ///        "abcd".dzHasNumbers -> false
    ///        "123abc".dzHasNumbers -> true
    ///
    var dzHasNumbers: Bool {
        return rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
    }
    
    /// 是否纯字母
    ///
    ///     "abc".dzIsAlphabetic -> true
    ///     "123abc".dzIsAlphabetic -> false
    ///
    var dzIsAlphabetic: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        return hasLetters && !hasNumbers
    }
    
    /// 是否是数字字母组合
    ///
    ///     "123abc".dzIsAlphaNumeric -> true
    ///     "abc".dzIsAlphaNumeric -> false
    ///
    var dzIsAlphaNumeric: Bool {
        let hasLetters = rangeOfCharacter(from: .letters, options: .numeric, range: nil) != nil
        let hasNumbers = rangeOfCharacter(from: .decimalDigits, options: .literal, range: nil) != nil
        let comps = components(separatedBy: .alphanumerics)
        return comps.joined(separator: "").count == 0 && hasLetters && hasNumbers
    }
    
    /// 是否纯数字
    ///
    ///     "123".dzIsDigits -> true
    ///     "1.3".dzIsDigits -> false
    ///     "abc".dzIsDigits -> false
    ///
    var dzIsDigits: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    
    /// 是否是数字，支持"."和","
    ///
    /// Note:
    /// In North America, "." is the decimal separator,
    /// while in many parts of Europe "," is used,
    ///
    ///     "123".dzIsNumeric -> true
    ///     "1.3".dzIsNumeric -> true (en_US)
    ///     "1,3".dzIsNumeric -> true (fr_FR)
    ///     "abc".dzIsNumeric -> false
    ///
    var dzIsNumeric: Bool {
        let scanner = Scanner(string: self)
        scanner.locale = NSLocale.current
        return scanner.scanDecimal(nil) && scanner.isAtEnd
    }
}

// MARK: - url
public extension String {
    /// 是否有效URL
    ///
    ///        "https://google.com".dzIsValidUrl -> true
    ///
    var dzIsValidUrl: Bool {
        return URL(string: self) != nil
    }

    /// 是否有效 schemed URL.
    ///
    ///        "https://google.com".dzIsValidSchemedUrl -> true
    ///        "google.com".dzIsValidSchemedUrl -> false
    ///
    var dzIsValidSchemedUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme != nil
    }

    /// 是否有效 https URL.
    ///
    ///        "https://google.com".dzIsValidHttpsUrl -> true
    ///
    var dzIsValidHttpsUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme == "https"
    }

    /// 是否有效 http URL.
    ///
    ///        "http://google.com".dzIsValidHttpUrl -> true
    ///
    var dzIsValidHttpUrl: Bool {
        guard let url = URL(string: self) else { return false }
        return url.scheme == "http"
    }

    /// 是否有效 file URL.
    ///
    ///        "file://Documents/file.txt".dzIsValidFileUrl -> true
    ///
    var dzIsValidFileUrl: Bool {
        return URL(string: self)?.isFileURL ?? false
    }
    
    /// URL解码
    ///
    ///        "it's%20easy%20to%20decode%20strings".dzUrlDecoded -> "it's easy to decode strings"
    ///
    var dzUrlDecoded: String {
        return removingPercentEncoding ?? self
    }

    /// URL编码
    ///
    ///        "it's easy to encode strings".dzUrlEncoded -> "it's%20easy%20to%20encode%20strings"
    ///
    var dzUrlEncoded: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

// MARK: - Date
public extension String {
    /// string->date;  default:"yyyy-MM-dd"
    ///
    ///        "2007-06-29".dzDate() -> Optional(Date)
    ///        "2007-06-29 14:23:09".dzDate(dateFormat: "yyyy-MM-dd HH:mm:ss") -> Optional(Date)
    ///
    func dzDate(dateFormat: String = "yyyy-MM-dd", timeZone: TimeZone = .current) -> Date? {
        let selfLowercased = trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = dateFormat
        return formatter.date(from: selfLowercased)
    }
}

// MARK: - Operators
public extension String {
    /// string 乘法操作
    ///
    ///        'bar' * 3 -> "barbarbar"
    ///
    /// - Parameters:
    ///   - lhs: string to repeat.
    ///   - rhs: number of times to repeat character.
    /// - Returns: new string with given string repeated n times.
    static func * (lhs: String, rhs: Int) -> String {
        guard rhs > 0 else { return "" }
        return String(repeating: lhs, count: rhs)
    }

    /// string 乘法操作
    ///
    ///        3 * 'bar' -> "barbarbar"
    ///
    /// - Parameters:
    ///   - lhs: number of times to repeat character.
    ///   - rhs: string to repeat.
    /// - Returns: new string with given string repeated n times.
    static func * (lhs: Int, rhs: String) -> String {
        guard lhs > 0 else { return "" }
        return String(repeating: rhs, count: lhs)
    }
}

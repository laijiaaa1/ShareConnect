//
//  Setting.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
extension DateFormatter {
    static let customDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月 dd, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}

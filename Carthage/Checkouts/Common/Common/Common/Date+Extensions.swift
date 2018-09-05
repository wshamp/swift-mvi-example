//
//  Date+Extensions.swift
//  cryptominingtracker
//
//  Created by Wyeth Shamp on 3/16/18.
//  Copyright © 2018 wyethshamp. All rights reserved.
//

import Foundation

public extension Date {
    public func timeAgo(numericDates:Bool = false) -> String {
        let calendar = Calendar.current
        let now = Date()
        let earliest = (now as NSDate).earlierDate(self)
        let latest = (earliest == now) ? self : now
        let components:DateComponents = (calendar as NSCalendar).components([NSCalendar.Unit.minute , NSCalendar.Unit.hour , NSCalendar.Unit.day , NSCalendar.Unit.weekOfYear , NSCalendar.Unit.month , NSCalendar.Unit.year , NSCalendar.Unit.second], from: earliest, to: latest, options: NSCalendar.Options())
        
        if let year = components.year, year > 0 {
            if numericDates && year == 1 {
                return "1 year ago"
            } else if year == 1 {
                return "last year"
            } else {
                return "\(year) years ago"
            }
        }
        
        if let month = components.month, month > 0 {
            if numericDates && month == 1 {
                return "1 month ago"
            } else if month == 1 {
                return "last month"
            } else {
                return "\(month) months ago"
            }
        }
        
        if let week = components.weekOfYear, week > 0 {
            if numericDates && week == 1 {
                return "1 week ago"
            } else if week == 1 {
                return "last week"
            } else {
                return "\(week) weeks ago"
            }
        }
        
        if let day = components.day, day > 0 {
            if numericDates && day == 1 {
                return "1 day ago"
            } else if day == 1 {
                return "yesterday"
            } else {
                return "\(day) days ago"
            }
        }
        
        if let hour = components.hour, hour > 0 {
            if numericDates && hour == 1 {
                return "1 hour ago"
            } else if hour == 1 {
                return "an hour ago"
            } else {
                return "\(hour) hours ago"
            }
        }
        
        if let minute = components.minute, minute > 0 {
            if numericDates && minute == 1 {
                return "1 minute ago"
            } else if minute == 1 {
                return "a minute ago"
            } else {
                return "\(minute) minutes ago"
            }
        }
        
        if let second = components.second, second >= 3 {
            return "\(second) seconds ago"
        }
        
        return "just now"
    }
}

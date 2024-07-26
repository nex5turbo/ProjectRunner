//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

extension Date {
    func toString(_ withHour: Bool = false) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = withHour ? "yyyy-MM-dd HH:mm" : "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    func endOfDayDate() -> Self {
        return Date(timeIntervalSince1970: self.timeIntervalSince1970.getLastTime())
    }
    
    func startOfDayDate() -> Self {
        return Date(timeIntervalSince1970: self.timeIntervalSince1970.getStartTime())
    }
}

extension Calendar {
    func timeLeft(from: Date, to: Date) -> String {
        let interval = to.timeIntervalSince(from)
        let minutes = interval / 60
        let hours = minutes / 60
        let days = hours / 24
        if days <= 1.0 {
            if hours <= 1.0 {
                if hours <= 0.0 {
                    return "Due date over"
                } else {
                    return "\(Int(minutes)) minutes left"
                }
            } else {
                return "\(Int(hours)) hours left"
            }
        } else {
            return "\(Int(days)) days left"
        }
    }
    
    func isStarted(of: Date) -> Bool {
        let interval = Date.now.timeIntervalSince(of)
        return interval > 0
    }
    
    func isOver(dueDate: Date) -> Bool {
        let interval = dueDate.timeIntervalSince(Date.now)
        print("isOver", Date.now.toString(true), dueDate.toString(true))
        print(interval <= 0, interval)
        return interval <= 0
    }
}

extension TimeInterval {
    
    func addingMonths(for months: Int) -> TimeInterval {
        let date = Date(timeIntervalSince1970: self)

        // Get the current calendar
        let calendar = Calendar.current

        // Extract the year, month, and day components from the date
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a new Date object with the time set to 23:59:59
        if let year = components.year, let month = components.month, let day = components.day {
            var endOfDayComponents = DateComponents()
            endOfDayComponents.year = year
            endOfDayComponents.month = month + months
            endOfDayComponents.day = day
            endOfDayComponents.hour = 0
            endOfDayComponents.minute = 0
            endOfDayComponents.second = 0
            
            if let endOfDay = calendar.date(from: endOfDayComponents) {
                print("End of day date: \(endOfDay)")
                return endOfDay.timeIntervalSince1970
            } else {
                print("Error creating end of day date")
                return self
            }
        } else {
            print("Error extracting date components")
            return self
        }
    }
    
    func addingWeeks(for weeks: Int) -> TimeInterval {
        return addingDays(for: weeks * 7)
    }
    
    func addingDays(for days: Int) -> TimeInterval {
        let date = Date(timeIntervalSince1970: self)

        // Get the current calendar
        let calendar = Calendar.current

        // Extract the year, month, and day components from the date
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a new Date object with the time set to 23:59:59
        if let year = components.year, let month = components.month, let day = components.day {
            var endOfDayComponents = DateComponents()
            endOfDayComponents.year = year
            endOfDayComponents.month = month
            endOfDayComponents.day = day + days
            endOfDayComponents.hour = 0
            endOfDayComponents.minute = 0
            endOfDayComponents.second = 0
            
            if let endOfDay = calendar.date(from: endOfDayComponents) {
                print("End of day date: \(endOfDay)")
                return endOfDay.timeIntervalSince1970
            } else {
                print("Error creating end of day date")
                return self
            }
        } else {
            print("Error extracting date components")
            return self
        }
    }
    
    func getStartTime() -> TimeInterval {
        // Assuming `timeInterval` is your TimeInterval value

        // Convert TimeInterval to Date
        let date = Date(timeIntervalSince1970: self)

        // Get the current calendar
        let calendar = Calendar.current

        // Extract the year, month, and day components from the date
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a new Date object with the time set to 23:59:59
        if let year = components.year, let month = components.month, let day = components.day {
            var endOfDayComponents = DateComponents()
            endOfDayComponents.year = year
            endOfDayComponents.month = month
            endOfDayComponents.day = day
            endOfDayComponents.hour = 0
            endOfDayComponents.minute = 0
            endOfDayComponents.second = 0
            
            if let endOfDay = calendar.date(from: endOfDayComponents) {
                print("End of day date: \(endOfDay)")
                return endOfDay.timeIntervalSince1970
            } else {
                print("Error creating end of day date")
                return self
            }
        } else {
            print("Error extracting date components")
            return self
        }
    }
    func getLastTime() -> TimeInterval {
        // Assuming `timeInterval` is your TimeInterval value

        // Convert TimeInterval to Date
        let date = Date(timeIntervalSince1970: self)

        // Get the current calendar
        let calendar = Calendar.current

        // Extract the year, month, and day components from the date
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        // Create a new Date object with the time set to 23:59:59
        if let year = components.year, let month = components.month, let day = components.day {
            var endOfDayComponents = DateComponents()
            endOfDayComponents.year = year
            endOfDayComponents.month = month
            endOfDayComponents.day = day
            endOfDayComponents.hour = 23
            endOfDayComponents.minute = 59
            endOfDayComponents.second = 59
            
            if let endOfDay = calendar.date(from: endOfDayComponents) {
                print("End of day date: \(endOfDay)")
                return endOfDay.timeIntervalSince1970
            } else {
                print("Error creating end of day date")
                return self
            }
        } else {
            print("Error extracting date components")
            return self
        }
    }
}

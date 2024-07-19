//
//  CalenderView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/16/24.
//

import SwiftUI

struct CalenderView: View {
    enum CalendarStyle: String, CaseIterable {
        case diary
        case task
    }
    @Binding var appData: AppData
    var years: [Int] = Array(2010...2099)
    var months: [Month] {
        years.flatMap { year in
            return Array(1...12).map { Month(year: year, value: $0) }
        }
    }
    @State private var selectedMonth: Month = Month(year: 2010, value: 1)
    @State private var selectedDay: Day = Day(year: 2010, month: 1, value: 1)
    @State private var isFetched: Bool = false
    
    @State private var calendarStyle: CalendarStyle = .diary
    var height: CGFloat {
        UIScreen.main.bounds.height * (3.0 / 5.0)
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(selectedMonth.id)
                    .font(.title2.weight(.semibold))
                    .onTapGesture {
                        withAnimation(.spring) {
                            setToCurrent()
                        }
                    }
                Spacer()
                Picker("", selection: $calendarStyle) {
                    ForEach(CalendarStyle.allCases, id: \.self) { style in
                        Text(style.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
            .padding()
            
            TabView(selection: $selectedMonth) {
                ForEach(months) { month in
                    CalendarMonth(
                        appData: $appData,
                        selectedDay: $selectedDay,
                        month: month
                    )
                    .tag(month)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            
            Spacer()
            // 여기에 다이어리 혹은 task를 어떻게 표현할 것인가?
        }
        .task {
            guard !isFetched else {
                return
            }
            isFetched = true
            setToCurrent()
        }
    }
    
    func setToCurrent() {
        let calendarManager = CalendarManager()
        let year = calendarManager.currentDateComponents.year!
        let month = calendarManager.currentDateComponents.month!
        let day = calendarManager.currentDateComponents.day!
        self.selectedMonth = Month(year: year, value: month)
        self.selectedDay = Day(year: year, month: month, value: day)
    }
}

struct CalendarMonth: View {
    let calendarManager = CalendarManager()
    @Binding var appData: AppData
    @Binding var selectedDay: Day
    let month: Month
    let columns: [GridItem] = [
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0),
        .init(.flexible(), spacing: 0)
    ]
    
    var dueDatedTasks: [TTask] {
        appData.tasks.filter { $0.hasDeadline }.sorted { $0.startDate < $1.startDate }
    }
    
    var days: Int? {
        calendarManager.getDays(month: month)
    }
    
    var firstWeekday: Int? {
        calendarManager.firstWeekday(month: month)
    }
    
    var weeks: Int? {
        guard let days, let firstWeekday else {
            return nil
        }
        if days + firstWeekday - 1 > 35 {
            return 6
        } else {
            return 5
        }
    }
    
    var lastMonthDays: Int? {
        return calendarManager.getDays(year: month.year, month: month.value - 1)
    }
    var lastMonthDayItems: [Day] {
        guard let lastMonthDays, let firstWeekday else {
            return []
        }
        return Array(min(lastMonthDays - firstWeekday + 2, lastMonthDays + 1)..<lastMonthDays + 1).map {
            Day(year: month.year, month: month.value - 1, value: $0)
        }
    }
    var dayItems: [Day] {
        guard let days else {
            return []
        }
        return Array(1...days).map {
            Day(year: month.year, month: month.value, value: $0)
        }
    }
    var height: CGFloat {
        UIScreen.main.bounds.height * (3.0 / 5.0)
    }
    var cellHeight: CGFloat {
        height / CGFloat(weeks ?? 6)
    }
    
    let colorHeight: CGFloat = 16
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            // last month day with gray color
            ForEach(lastMonthDayItems, id: \.self) { item in
                VStack(spacing: 4) {
                    HStack {
                        dayText(day: item, isLastMonth: true)
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(height: cellHeight)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDay = item
                }
            }
            
            // current month day with black and red color
            ForEach(dayItems, id: \.self) { item in
                VStack(spacing: 4) {
                    HStack {
                        dayText(day: item, isLastMonth: false)
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(height: cellHeight)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDay = item
                }
            }
        }
        .frame(height: height)
        .padding(.horizontal)
    }
    
    @ViewBuilder func dayText(day: Day, isLastMonth: Bool) -> some View {
        let textColor: Color = {
            if selectedDay == day {
                return .white
            } else {
                if isLastMonth {
                    return .gray
                } else {
                    if day.isHoliday {
                        return .red
                    } else {
                        return .black
                    }
                }
            }
        }()
        Text("\(day.value)")
            .foregroundStyle(textColor)
            .padding(6)
            .overlay {
                if day.isToday {
                    Circle()
                        .fill(.clear)
                        .stroke(.gray, lineWidth: 1)
                }
            }
            .background(day == selectedDay ? .blue : .clear)
            .clipShape(Circle())
            .clipped()
    }
}

struct Month: Identifiable, Hashable {
    var id: String {
        "\(year)/\(value)"
    }
    var year: Int
    var value: Int
    init(year: Int, value: Int) {
        self.year = year
        self.value = value
        if value <= 0 {
            self.year = self.year - 1
            self.value = 12 - self.value
        }
    }
}

struct Day: Identifiable, Hashable {
    var id: String { "\(year)/\(month)\(value)" }
    var year: Int
    var month: Int
    var value: Int
    var isHoliday: Bool {
        let components = DateComponents(year: year, month: month, day: value)
        let cal = Calendar.current
        guard let date = cal.date(from: components) else {
            return false
        }
        let result = cal.component(.weekday, from: date)
        return result == 1 || result == 7
    }
    var toDate: Date? {
        let comp = DateComponents(year: year, month: month, day: value)
        let cal = Calendar.current
        return cal.date(from: comp)
    }
    var isToday: Bool {
        let calendarManager = CalendarManager()
        let year = calendarManager.currentDateComponents.year!
        let month = calendarManager.currentDateComponents.month!
        let day = calendarManager.currentDateComponents.day!
        return year == self.year && month == self.month && day == self.value
    }
}

#Preview {
    CalenderView(appData: .constant(.init()))
}

class CalendarManager {
    var calendar: Calendar = Calendar.current
    var currentDateComponents: DateComponents {
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear, .yearForWeekOfYear], from: Date.now)
    }
    
    func dateComponents(year: Int, month: Int) -> DateComponents {
        var dateComponents: DateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        return dateComponents
    }
    
    func getDays(month: Month) -> Int? {
        return getDays(year: month.year, month: month.value)
    }
    
    func firstWeekday(month: Month) -> Int? {
        return firstWeekday(year: month.year, month: month.value)
    }
    
    func getDays(year: Int, month: Int) -> Int? {
        let dateComponents = dateComponents(year: year, month: month)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return nil
        }
        guard let daysCount = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count else {
            return nil
        }
        return daysCount
        
    }
    
    func firstWeekday(year: Int, month: Int) -> Int? {
        let dateComponents = dateComponents(year: year, month: month)
        guard let firstDayOfMonth = calendar.date(from: dateComponents) else {
            return nil
        }
        guard let daysCount = calendar.range(of: .day, in: .month, for: firstDayOfMonth)?.count else {
            return nil
        }
        return calendar.component(.weekday, from: firstDayOfMonth)
    }
}

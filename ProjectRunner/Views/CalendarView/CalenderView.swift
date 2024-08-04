//
//  CalenderView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/16/24.
//

import SwiftUI

enum CalendarStyle: String, CaseIterable {
    case task
    case diary
    
    var tintColor: Color {
        switch self {
        case .diary:
                .pink
        case .task:
                .blue
        }
    }
}

enum Days: String, CaseIterable {
    case SUN
    case MON
    case TUE
    case WED
    case THU
    case FRI
    case SAT
}

struct CalenderView: View {
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
    
    @State private var calendarStyle: CalendarStyle = .task
    @State private var isDiarySheetPresented: Bool = false
    
    var selectedDaysTasks: [TTask] {
        return appData.tasks.filter {
            if let date = selectedDay.toDate {
                return $0.hasDeadline && $0.isIn(date: date)
            } else {
                return false
            }
        }
    }
    
    var height: CGFloat {
        UIScreen.main.bounds.height * 0.4
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                .pickerStyle(SegmentedPickerStyle())
                .fixedSize()
            }
            .padding()
            
            HStack {
                ForEach(Days.allCases, id: \.self) { day in
                    Text(day.rawValue)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            
            TabView(selection: $selectedMonth) {
                ForEach(months) { month in
                    CalendarMonth(
                        appData: $appData,
                        selectedDay: $selectedDay,
                        calendarStyle: $calendarStyle,
                        month: month
                    )
                    .tag(month)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: height)
            Divider()
            ZStack(alignment: .bottomTrailing) {
                switch calendarStyle {
                case .diary:
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                        }
                        .frame(height: 1)
                        Text(selectedDay.toDate?.toString() ?? "Date Error")
                            .font(.title2)
                            .padding(.bottom)
                        if let diary = appData.getDiary(day: selectedDay) {
                            Text(diary.content)
                        } else {
                            Text("How was your day?")
                                .foregroundStyle(.gray)
                                .onTapGesture {
                                    self.isDiarySheetPresented.toggle()
                                }
                        }
                        Spacer()
                    }
                    .padding()
                case .task:
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(selectedDaysTasks) { task in
                                ScheduleItemView(schedule: task, appData: $appData)
                            }
                        }
                    }
                }
                
                switch calendarStyle {
                case .diary:
                    Button {
                        if let diary = appData.getDiary(day: selectedDay) {
                            do {
                                try appData.deleteDiary(diary: diary)
                            } catch {
                                print(error.localizedDescription)
                            }
                        } else {
                            self.isDiarySheetPresented.toggle()
                        }
                    } label: {
                        let size: CGFloat = 40
                        let iconName: String = {
                            if appData.getDiary(day: selectedDay) != nil {
                                return "trash.fill"
                            } else {
                                return "plus"
                            }
                        }()
                        Circle().fill(calendarStyle.tintColor)
                            .frame(width: size, height: size)
                            .overlay {
                                Image(systemName: iconName)
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                    }
                    .padding()
                    .sheet(isPresented: $isDiarySheetPresented) {
                        DiaryAddSheet(day: selectedDay, appData: $appData)
                    }
                case .task:
                    NavigationLink {
                        if let date = selectedDay.toDate {
                            TaskAddView(dueDate: date, appData: $appData)
                        } else {
                            TaskAddView(appData: $appData)
                        }
                    } label: {
                        let size: CGFloat = 40
                        Circle().fill(calendarStyle.tintColor)
                            .frame(width: size, height: size)
                            .overlay {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(.white)
                            }
                    }
                    .padding()
                }
                
            }
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: UIColor.secondarySystemGroupedBackground))
            .safeAreaPadding(.bottom)
            
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
    @Binding var calendarStyle: CalendarStyle
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
        appData.tasks.filter { $0.hasDeadline }.sorted { $0.createdAt < $1.createdAt }
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
        UIScreen.main.bounds.height * 0.4
    }
    var cellHeight: CGFloat {
        height / CGFloat(weeks ?? 6)
    }
    
    let colorHeight: CGFloat = 16
    var body: some View {
        LazyVGrid(columns: columns, spacing: 0) {
            // last month day with gray color
            ForEach(lastMonthDayItems, id: \.self) { item in
                Color.clear
                    .frame(height: cellHeight)
                    .frame(maxWidth: .infinity)
            }
            
            // current month day with black and red color
            ForEach(dayItems, id: \.self) { item in
                VStack(spacing: 4) {
                    dayText(day: item, isLastMonth: false)
                    
                    let has: Bool = {
                        switch calendarStyle {
                        case .diary:
                            if let itemDate = item.toDate {
                                return appData.diaries.contains { $0.createdDay.isSame(with: itemDate) }
                                
                            } else {
                                return false
                            }
                            
                        case .task:
                            return appData.tasks.contains { $0.hasDeadline && $0.isIn(dayItem: item) }
                            
                        }
                    }()
                    if has {
                        Circle().fill(calendarStyle.tintColor.opacity(0.5))
                            .frame(width: 6, height: 6)
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

struct Day: Identifiable, Hashable, Codable {
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
    
    func isSame(with date: Date) -> Bool {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return year == comps.year! &&
        month == comps.month! &&
        value == comps.day!
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

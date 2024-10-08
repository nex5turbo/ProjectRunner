//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ProjectView: View {
    @AppStorage("projectSort") private var groupingType: GroupingType = .priority
    @Binding var appData: AppData
    @State private var isSortFilterPresented: Bool = false
    @AppStorage("timeline") private var shouldShowTimeline = false
    @AppStorage("showDone") private var shouldShowDone = false
    
    private let titleFont: Font = .headline
    
    var projectListWithDone: [TProject] {
        if !shouldShowDone {
            return appData.projects.filter { $0.status != .done && $0.status != .canceled }
        } else {
            return appData.projects
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if appData.projects.isEmpty {
                navigationTopItems()
                VStack {
                    Spacer()
                    Text("No active project")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
            } else {
                navigationTopItems()
                switch groupingType {
                case .plain:
                    plainList()
                case .color:
                    colorSortedList()
                case .status:
                    statusSortedList()
                case .priority:
                    prioritySortedList()
                case .date:
                    dateSortedList()
                case .label:
                    labelSortedList()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Project")
    }
    
    @ViewBuilder func navigationTopItems() -> some View {
        NavigationTopItems {
            NavigationLink {
                ProjectAddView(
                    appData: $appData
                )
            } label: {
                TopButtonChip(title: "New Project", imageName: "plus", isSystem: true) {
                    
                }
            }
            
            Menu {
                ForEach(GroupingType.allCases, id: \.self) { type in
                    Button {
                        self.groupingType = type
                    } label: {
                        Text(type.title)
                    }
                }
            } label: {
                TopButtonChip(title: groupingType.title, imageName: "arrow.up.arrow.down", isSystem: true) {
                }
            }
            
            Button {
                withAnimation(.spring) {
                    self.shouldShowDone = !self.shouldShowDone
                }
            } label: {
                TopButtonChip(title: "Hide Done", imageName: !self.shouldShowDone ? "checkmark.square" : "square", isSystem: true) {
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}


extension ProjectView {
    var priorityProjectList: [String: [TProject]] {
        var test: [String: [TProject]] = [:]
        Priority.allCases.forEach { type in
            test[type.title] = projectListWithDone.filter { $0.priority.title == type.title }
        }
        return test
    }
    
    var colorProjectList: [String: [TProject]] {
        var returnValue: [String: [TProject]] = [:]
        MarkColor.allCases.forEach { color in
            returnValue[color.title] = projectListWithDone.filter { $0.markColor.title == color.title }
        }
        return returnValue
    }
    
    var statusProjectList: [String: [TProject]] {
        var returnValue: [String: [TProject]] = [:]
        Status.allCases.forEach { status in
            if status == .done && !shouldShowDone {
                return
            }
            returnValue[status.title] = projectListWithDone.filter { $0.status.title == status.title }
        }
        return returnValue
    }
    
    var dateProjectList: [String: [TProject]] {
        var returnValue: [String: [TProject]] = [:]
        var dates: Set<String> = []
        projectListWithDone.forEach {
            if $0.hasDeadline {
                dates.insert($0.dueDate.toString(false))
            }
        }
        dates.insert("No Due date")
        dates.forEach { date in
            returnValue[date] = projectListWithDone.filter { $0.dueDate.toString(false) == date && $0.hasDeadline }
        }
        returnValue["No Due date"] = projectListWithDone.filter { !$0.hasDeadline }
        return returnValue
    }
    
    var labelProjectList: [String: [TProject]] {
        var returnValue: [String: [TProject]] = [:]
        appData.labels.forEach { label in
            returnValue[label.content] = projectListWithDone.filter { task in
                task.labels.contains { $0.content == label.content }
            }
        }
        
        return returnValue
    }
    
    @ViewBuilder func labelSortedList() -> some View {
        if !appData.labels.isEmpty {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(appData.labels, id: \.self) { label in
                        if let list = labelProjectList[label.content], !list.isEmpty {
                            HStack {
                                Text(label.content)
                                    .font(titleFont)
                                CountChip(count: list.count)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            projectList(list: list)
                        }
                    }
                }
            }
        } else {
            VStack {
                Spacer()
                Text("No label list")
                Spacer()
            }
        }
    }
    
    @ViewBuilder func plainList() -> some View {
        ScrollView {
            projectList(list: projectListWithDone)
        }
    }
    
    @ViewBuilder func projectList(list: [TProject]) -> some View {
        VStack(spacing: 0) {
            ForEach(list, id: \.self) { project in
                ScheduleItemView(schedule: project, appData: $appData)
            }
        }
    }
    
    @ViewBuilder func colorSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(MarkColor.allCases, id: \.self) { color in
                    if let list = colorProjectList[color.title], !list.isEmpty {
                        HStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(color.color)
                                .frame(width: 32, height: 16)
                                .shadow(radius: 1, y: 1)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        projectList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func statusSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Status.listForSort(), id: \.self) { status in
                    if let list = statusProjectList[status.title], !list.isEmpty {
                        HStack {
                            Text(status.title)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        projectList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func prioritySortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    if let list = priorityProjectList[priority.title], !list.isEmpty {
                        HStack {
                            Text(priority.title)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        projectList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func dateSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                let sortedDateKey = Array(dateProjectList.keys)
                    .filter {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        return dateFormatter.date(from: $0) != nil
                    }
                    .sorted {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        return dateFormatter.date(from: $0)! < dateFormatter.date(from: $1)!
                    } + ["No Due date"]
                ForEach(sortedDateKey, id: \.self) { date in
                    if let list = dateProjectList[date], !list.isEmpty {
                        HStack {
                            Text(date)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        projectList(list: list)
                    }
                }
            }
        }
    }
}

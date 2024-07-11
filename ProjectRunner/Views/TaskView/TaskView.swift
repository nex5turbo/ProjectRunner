//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

enum GroupingType: String, CaseIterable {
    case plain
    case color
    case status
    case priority
    case date
    case label
    
    var title: String {
        return switch self {
        case .plain:
            "Grouping"
        case .color:
            "Color"
        case .status:
            "Status"
        case .priority:
            "Priority"
        case .date:
            "Due date"
        case .label:
            "Label"
        }
    }
}

struct TaskView: View {
    @AppStorage("taskSort") private var groupingType: GroupingType = .priority
    @Binding var appData: AppData
    @AppStorage("timeline") private var shouldShowTimeline = false
    @AppStorage("showDone") private var shouldShowDone = false
    @AppStorage("selectedProjectId") private var selectedProjectId: String = "All Tasks"
    @State private var selectedProject: TProject? = nil
    @State private var filterOptions: FilterOptions = .init()
    @State private var isFilterSheetPresented: Bool = false
    
    let titleFont: Font = .headline
    
    var taskListWithProject: [TTask] {
        switch selectedProjectId {
        case "Todo":
            return appData.tasks.filter { $0.superiorId == nil }
        case "All Tasks":
            return appData.tasks
        default:
            let sortedTasks = appData.tasks.filter { $0.superiorId == selectedProjectId }
            var returnTask: [TTask] = sortedTasks
            sortedTasks.forEach { task in
                returnTask = getAllTasks(current: task, tasks: returnTask)
            }
            return returnTask
        }
    }
    
    func getAllTasks(current: TTask, tasks: [TTask]) -> [TTask] {
        
        guard !current.taskIds.isEmpty else {
            return tasks
        }
        var tasks = tasks
        current.taskIds.forEach { id in
            guard let ctask = appData.tasks.first(where: { $0.id == id }) else {
                return
            }
            tasks.append(ctask)
            tasks = getAllTasks(current: ctask, tasks: tasks)
        }
        return tasks
    }
    
    var taskListWithDone: [TTask] {
        if !shouldShowDone {
            return taskListWithProject.filter { $0.status != .done && $0.status != .canceled }
        } else {
            return taskListWithProject
        }
    }
    
    var filtered: [TTask] {
        return taskListWithDone.filter { task in
            var result: Bool = true
            if !filterOptions.colors.isEmpty {
                if filterOptions.colors.contains(task.markColor) {
                    return true
                } else {
                    result = false
                }
            }
            if !filterOptions.status.isEmpty {
                if filterOptions.status.contains(task.status) {
                    return true
                } else {
                    result = false
                }
            }
            if !filterOptions.priorities.isEmpty {
                if filterOptions.priorities.contains(task.priority) {
                    return true
                } else {
                    result = false
                }
            }
            if !filterOptions.labels.isEmpty {
                if filterOptions.labels.contains(task.labels) {
                    return true
                } else {
                    result = false
                }
            }
            return result
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if appData.tasks.isEmpty {
                navigationTopItems()
                VStack {
                    Spacer()
                    Text("No active task")
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
        .navigationTitle(
            selectedProject != nil ? selectedProject!.name : selectedProjectId == "All Tasks" || selectedProjectId == "Todo" ? selectedProjectId : "Loading..."
        )
        .toolbarTitleMenu {
            Section {
                Button {
                    self.selectedProjectId = "All Tasks"
                } label: {
                    Text("All Tasks")
                }
                Button {
                    self.selectedProjectId = "Todo"
                } label: {
                    Text("Todo")
                }
            }
            Section {
                ForEach(appData.projects, id: \.self) { project in
                    Button {
                        self.selectedProjectId = project.id
                    } label: {
                        Text(project.name)
                    }
                }
            }
        }
        .onChange(of: selectedProjectId) {
            selectedProject = appData.projects.first(where: { $0.id == selectedProjectId })
        }
        .task {
            selectedProject = appData.projects.first(where: { $0.id == selectedProjectId })
        }
    }
    @ViewBuilder func navigationTopItems() -> some View {
        NavigationTopItems {
            NavigationLink {
                if let selectedProject {
                    TaskAddView(
                        superior: selectedProject, appData: $appData) { _ in }
                } else {
                    TaskAddView(
                        appData: $appData
                    )
                }
            } label: {
                TopButtonChip(title: "New Task", imageName: "plus", isSystem: true) {
                    
                }
            }
            
            Button {
                self.isFilterSheetPresented.toggle()
            } label: {
                TopButtonChip(title: "Filtering", imageName: "line.3.horizontal.decrease", isSystem: true) {
                    
                }
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                FilterSheet(filterOptions: filterOptions, appData: $appData) { filterOptions in
                    self.filterOptions = filterOptions
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
                TopButtonChip(title: self.groupingType.title, imageName: "arrow.up.arrow.down", isSystem: true) {
                    
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

extension TaskView {
    
    var priorityTaskList: [String: [TTask]] {
        var test: [String: [TTask]] = [:]
        Priority.allCases.forEach { type in
            test[type.title] = taskListWithDone.filter { $0.priority.title == type.title }
        }
        return test
    }
    
    var colorTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        MarkColor.allCases.forEach { color in
            returnValue[color.title] = taskListWithDone.filter { $0.markColor.title == color.title }
        }
        return returnValue
    }
    
    var statusTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        Status.allCases.forEach { status in
            if status == .done && !shouldShowDone {
                return
            }
            returnValue[status.title] = taskListWithDone.filter { $0.status.title == status.title }
        }
        return returnValue
    }
    
    var dateTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        var dates: Set<String> = []
        taskListWithDone.forEach {
            if $0.hasDeadline {
                dates.insert($0.dueDate.toString(false))
            }
        }
        dates.insert("No Due date")
        dates.forEach { date in
            returnValue[date] = taskListWithDone.filter { $0.dueDate.toString(false) == date && $0.hasDeadline && $0.dueDate > Date.now }
        }
        returnValue["No Due date"] = taskListWithDone.filter { !$0.hasDeadline }
        returnValue["Over due"] = taskListWithDone.filter { $0.hasDeadline && $0.dueDate < Date.now }
        return returnValue
    }
    
    var labelTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        appData.labels.forEach { label in
            returnValue[label.content] = taskListWithDone.filter { task in
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
                        if let list = labelTaskList[label.content], !list.isEmpty {
                            HStack {
                                Text(label.content)
                                    .font(titleFont)
                                CountChip(count: list.count)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            
                            taskList(list: list)
                        }
                    }
                }
            }
        } else {
            VStack {
                Spacer()
                Text("No label list")
                Text("TODO: - illustration or text")
                Spacer()
            }
        }
    }
    
    @ViewBuilder func plainList() -> some View {
        ScrollView {
            taskList(list: filtered)
        }
    }
    
    @ViewBuilder func taskList(list: [TTask]) -> some View {
        VStack(spacing: 0) {
            ForEach(list, id: \.self) { task in
                ScheduleItemView(schedule: task, appData: $appData)
                    .navigatable()
            }
        }
        .padding(.bottom)
    }
    
    @ViewBuilder func colorSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(MarkColor.allCases, id: \.self) { color in
                    if let list = colorTaskList[color.title], !list.isEmpty {
                        HStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(color.color)
                                .frame(width: 32, height: 16)
                                .shadow(radius: 1, y: 1)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        
                        taskList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func statusSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Status.listForSort(), id: \.self) { status in
                    if let list = statusTaskList[status.title], !list.isEmpty {
                        HStack {
                            Text(status.title)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        taskList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func prioritySortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    if let list = priorityTaskList[priority.title], !list.isEmpty {
                        HStack {
                            Text(priority.title)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        taskList(list: list)
                    }
                }
            }
        }
    }
    
    @ViewBuilder func dateSortedList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                let sortedDateKey = Array(dateTaskList.keys)
                    .filter {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        
                        return dateFormatter.date(from: $0) != nil
                    }
                    .sorted {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        return dateFormatter.date(from: $0)! < dateFormatter.date(from: $1)!
                    } + ["No Due date"] + ["Over due"]
                ForEach(sortedDateKey, id: \.self) { date in
                    if let list = dateTaskList[date], !list.isEmpty {
                        HStack {
                            Text(date)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        
                        taskList(list: list)
                    }
                }
            }
        }
    }
}

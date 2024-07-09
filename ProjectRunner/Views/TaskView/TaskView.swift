//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

enum TaskSortType: String, CaseIterable {
    case color
    case status
    case priority
    case date
    case label
    
    var title: String {
        return switch self {
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
    @AppStorage("taskSort") private var sortType: TaskSortType = .priority
    @Binding var appData: AppData
    @AppStorage("timeline") private var shouldShowTimeline = false
    @AppStorage("showDone") private var shouldShowDone = false
    @AppStorage("selectedProjectId") private var selectedProjectId: String = "All Tasks"
    @State private var selectedProject: TProject? = nil
    
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
    
    var body: some View {
        VStack {
            if appData.tasks.isEmpty {
                VStack {
                    Spacer()
                    Text("No active task")
                        .font(.headline)
                        .bold()
                    Spacer()
                }
            } else {
                switch sortType {
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
            selectedProject != nil ? selectedProject!.name : selectedProjectId
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
        .safeAreaInset(edge: .top, content: {
            navigationTopItems()
        })
    }
    @ViewBuilder func navigationTopItems() -> some View {
        NavigationTopItems {
            NavigationLink {
                TaskAddView(
                    appData: $appData
                )
            } label: {
                TopButtonChip(title: "New Task", imageName: "plus", isSystem: true) {
                    
                }
            }
            
            Menu {
                ForEach(TaskSortType.allCases, id: \.self) { type in
                    Button {
                        self.sortType = type
                    } label: {
                        Text(type.title)
                    }
                }
            } label: {
                TopButtonChip(title: "Filtering", imageName: "arrow.up.arrow.down", isSystem: true) {
                    
                }
            }
            
//            Button {
//                withAnimation(.spring) {
//                    self.shouldShowTimeline = !self.shouldShowTimeline
//                }
//            } label: {
//                TopButtonChip(title: "Timeline", imageName: self.shouldShowTimeline ? "checkmark.square" : "square", isSystem: true) {
//                    
//                }
//            }
//            
            
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
            returnValue[date] = taskListWithDone.filter { $0.dueDate.toString(false) == date && $0.hasDeadline }
        }
        returnValue["No Due date"] = taskListWithDone.filter { !$0.hasDeadline }
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
                            .padding(.horizontal)
                            
                            taskList(list: list)
                        }
                    }
                }
                .padding(.top, 8)
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
    
    @ViewBuilder func taskList(list: [TTask]) -> some View {
        VStack(spacing: 0) {
            ForEach(list, id: \.self) { task in
                ScheduleItemView(schedule: task, appData: $appData)
                    .navigatable()
            }
        }
        .padding(.top, 8)
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
                        .padding(.horizontal)
                        
                        taskList(list: list)
                    }
                }
            }
            .padding(.top, 8)
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
                        
                        taskList(list: list)
                    }
                }
            }
            .padding(.top, 8)
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
                        
                        taskList(list: list)
                    }
                }
            }
            .padding(.top, 8)
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
                    } + ["No Due date"]
                ForEach(sortedDateKey, id: \.self) { date in
                    if let list = dateTaskList[date], !list.isEmpty {
                        HStack {
                            Text(date)
                            CountChip(count: list.count)
                            Spacer()
                        }
                        .font(titleFont)
                        .padding(.horizontal)
                        
                        taskList(list: list)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}

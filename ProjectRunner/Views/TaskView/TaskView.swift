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
    @AppStorage("selectedProjectId") private var selectedProjectId: String = "FA86C984-5BAF-4361-BFBB-21DE6CE5EC50"
    @State private var selectedProject: TProject? = nil
    @State private var filterOptions: FilterOptions = .init()
    @State private var isFilterSheetPresented: Bool = false
    @State private var selectedTasks: [Schedulable] = []
    @AppStorage("shouldShowPinned") private var shouldShowPinned: Bool = false
    @State private var pinnedIds: [String] = [] {
        didSet {
            UserDefaults.standard.setValue(pinnedIds, forKey: "pinnedIds")
        }
    }
    var pinnedTasks: [TTask] {
        appData.tasks.filter { pinnedIds.contains($0.id) }
    }
    
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
            return taskListWithProject.filter { $0.status != .done && $0.status != .canceled }.sorted(by: { $0.createdAt < $1.createdAt })
        } else {
            return taskListWithProject.sorted(by: { $0.createdAt < $1.createdAt })
        }
    }
    
    var filtered: [TTask] {
        let fromDate = filterOptions.fromDate
        let toDate = filterOptions.toDate
        
        let isColorEmpty = filterOptions.colors.isEmpty
        let isStatusEmpty = filterOptions.status.isEmpty
        let isPriorityEmpty = filterOptions.priorities.isEmpty
        let isLabelEmpty = filterOptions.labels.isEmpty
        let isTextBlank = filterOptions.searchText != ""
        let hasSubTask = filterOptions.hasSubTask
        return taskListWithDone.filter { task in
            
            if filterOptions.isDateOn {
                if !task.hasDeadline {
                    return false
                }
                if fromDate?.date ?? Date(timeIntervalSince1970: .zero) > task.dueDate ||
                    toDate?.date ?? Date(timeIntervalSince1970: .infinity) < task.dueDate {
                    return false
                }
            }
            
            if !isColorEmpty {
                if !filterOptions.colors.contains(task.markColor) {
                    return false
                }
            }
            if !isStatusEmpty {
                if !filterOptions.status.contains(task.status) {
                    return false
                }
            }
            if !isPriorityEmpty {
                if !filterOptions.priorities.contains(task.priority) {
                    return false
                }
            }
            if !isLabelEmpty {
                if !filterOptions.labels.contains(task.labels) {
                    return false
                }
            }
            if !isTextBlank {
                if !task.contains(string: filterOptions.searchText) {
                    return false
                }
            }
            
            if let hasSubTask {
                if hasSubTask {
                    return !task.taskIds.isEmpty
                } else {
                    return task.taskIds.isEmpty
                }
            }
            
            return true
        }
    }
    
    func pin() {
        self.pinnedIds = selectedTasks.map { $0.id }
        self.selectedTasks = []
    }
    
    func delete() {
        self.selectedTasks.forEach { task in
            do {
                try appData.delete(schedule: task, shouldDeleteSubTasks: true)
            } catch {
                print(error.localizedDescription)
            }
        }
        self.selectedTasks = []
    }
    
    var body: some View {
        ZStack {
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
                        .searchable(text: $filterOptions.searchText)
                    ZStack {
                        VStack(spacing: 0) {
                            if shouldShowPinned {
                                HStack {
                                    Text("Pinned")
                                        .font(titleFont)
                                    CountChip(count: pinnedIds.count)
                                    Spacer()
                                    if !pinnedTasks.isEmpty {
                                        Button {
                                            self.pinnedIds = []
                                        } label: {
                                            Text("Clear")
                                                .font(.footnote)
                                                .foregroundStyle(.gray)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                if pinnedTasks.isEmpty {
                                    Text("You can set maximum 3 pins")
                                        .font(.footnote.weight(.semibold))
                                        .padding()
                                } else {
                                    ForEach(pinnedTasks, id :\.self) { task in
                                        ScheduleItemView(schedule: task, appData: $appData)
                                    }
                                }
                            }
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
                        VStack(spacing: 0) {
                            if shouldShowPinned {
                                HStack {
                                    Text("Pinned")
                                        .font(titleFont)
                                    CountChip(count: pinnedIds.count)
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                
                                if pinnedTasks.isEmpty {
                                    VStack(spacing: 0) {
                                        HStack {
                                            Text("You can set maximum 3 pins")
                                                .font(.footnote.weight(.semibold))
                                                
                                        }.padding()
                                        
                                        Divider()
                                    }
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 8)
                                } else {
                                    VStack(spacing: 0) {
                                        ForEach(pinnedTasks, id :\.self) { task in
                                            ScheduleItemView(schedule: task, appData: $appData)
                                        }
                                    }
                                    .shadow(color: .black.opacity(0.1), radius: 8, y: 8)
                                }
                            }
                            HStack {
                                Spacer()
                                Button {
                                    self.shouldShowPinned.toggle()
                                } label: {
                                    Image(systemName: shouldShowPinned ? "chevron.up" : "chevron.down")
                                        .padding(8)
                                        .font(.footnote)
                                        .background(.gray.opacity(0.6))
                                        .foregroundStyle(.white)
                                        .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                                }
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                    }
                    .animation(.spring, value: shouldShowPinned)
                }
            }
        }
        .task {
            self.pinnedIds = UserDefaults.standard.stringArray(forKey: "pinnedIds") ?? []
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
    
    @State private var deleteConfirm: Bool = false
    @State private var pinConfirm: Bool = false
    
    @ViewBuilder func navigationTopItems() -> some View {
        NavigationTopItems {
            if !selectedTasks.isEmpty {
                HStack {
                    Button {
                        deleteConfirm.toggle()
                    } label: {
                        TopButtonChip(title: "Delete \(selectedTasks.count) tasks", imageName: "trash.fill", isSystem: true) {
                            
                        }
                        .setImageColor(.red)
                    }
                    .alert("Are you sure to delete \(selectedTasks.count) tasks?", isPresented: $deleteConfirm) {
                        Button("Cancel", role: .cancel) {
                            
                        }
                        Button("Delete", role: .destructive) {
                            delete()
                        }
                    }
                    if selectedTasks.count < 4 {
                        Button {
                            pinConfirm.toggle()
                        } label: {
                            TopButtonChip(title: "Pin \(selectedTasks.count) tasks", imageName: "pin.fill", isSystem: true) {
                                
                            }
                            .setImageColor(.yellow)
                        }
                        .alert("Are you sure to remove \(pinnedIds.count) pinned tasks and pin \(selectedTasks.count) new tasks?", isPresented: $pinConfirm) {
                            Button("Cancel", role: .cancel) {
                                
                            }
                            Button("Pin") {
                                pin()
                            }
                        }
                    }
                    
                    Menu {
                        ForEach(Status.allCases, id: \.self) { status in
                            Button {
                                do {
                                    for task in selectedTasks {
                                        try appData.setStatus(schedule: task, to: status)
                                    }
                                    self.selectedTasks = []
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Text(status.title)
                                Image(systemName: status.systemName)
                            }
                        }
                    } label: {
                        TopButtonChip(title: "Change status", imageName: "circle.dashed", isSystem: true) {
                            
                        }
                        .setImageColor(.teal)
                    }
                }
            }
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
                .isSelected(filterOptions.isActivated)
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
        .animation(.spring, value: selectedTasks.count)
    }
}

#Preview {
    ContentView()
}

extension TaskView {
    
    var priorityTaskList: [String: [TTask]] {
        var test: [String: [TTask]] = [:]
        Priority.allCases.forEach { type in
            test[type.title] = filtered.filter { $0.priority.title == type.title }
        }
        return test
    }
    
    var colorTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        MarkColor.allCases.forEach { color in
            returnValue[color.title] = filtered.filter { $0.markColor.title == color.title }
        }
        return returnValue
    }
    
    var statusTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        Status.allCases.forEach { status in
            if status == .done && !shouldShowDone {
                return
            }
            returnValue[status.title] = filtered.filter { $0.status.title == status.title }
        }
        return returnValue
    }
    
    var dateTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        var dates: Set<String> = []
        filtered.forEach {
            if $0.hasDeadline {
                dates.insert($0.dueDate.toString(false))
            }
        }
        dates.insert("No Due date")
        dates.forEach { date in
            returnValue[date] = filtered.filter { $0.dueDate.toString(false) == date && $0.hasDeadline && $0.dueDate > Date.now }
        }
        returnValue["No Due date"] = filtered.filter { !$0.hasDeadline }
        returnValue["Over due"] = filtered.filter { $0.hasDeadline && $0.dueDate < Date.now }
        return returnValue
    }
    
    var labelTaskList: [String: [TTask]] {
        var returnValue: [String: [TTask]] = [:]
        appData.labels.forEach { label in
            returnValue[label.content] = filtered.filter { task in
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
                Spacer()
            }
        }
    }
    
    @ViewBuilder func plainList() -> some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("All Tasks")
                    CountChip(count: filtered.count)
                    Spacer()
                }
                .font(titleFont)
                .padding(.horizontal)
                .padding(.vertical, 8)
                taskList(list: filtered)
            }
        }
    }
    
    @ViewBuilder func taskList(list: [TTask]) -> some View {
        VStack(spacing: 0) {
            ForEach(list, id: \.self) { task in
                ScheduleItemView(schedule: task, appData: $appData)
                    .isSelected(in: $selectedTasks)
            }
        }
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

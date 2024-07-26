//
//  DetailView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/10/24.
//

import SwiftUI
import GoogleMobileAds

struct DetailView: View {
    @State private var schedule: Schedulable
    @Binding var appData: AppData
    @Environment(\.dismiss) private var dismiss
    
    @State private var isDeleteConfirm: Bool = false
    
    @AppStorage("showDone") private var shouldShowDone = false
    @AppStorage("isTaskFolded") private var isTaskFolded: Bool = false
    
    var titlePrompt: String {
        if task != nil {
            return "Task title..."
        } else if project != nil {
            return "Project title..."
        } else {
            return "Title..."
        }
    }
    
    var task: TTask? {
        return schedule as? TTask
    }
    
    var project: TProject? {
        return schedule as? TProject
    }
    
    init(schedule: Schedulable, appData: Binding<AppData>) {
        self._schedule = State(initialValue: schedule)
        self._appData = appData
    }
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("", text: $schedule.name, prompt: Text(titlePrompt))
                            .font(.title2)
                            .padding(.horizontal)
                            .bold()
                        NavigationTopItems {
                            Menu { // priority
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Button {
                                        do {
                                            try appData.setPriority(schedule: schedule, to: priority)
                                            self.schedule.priority = priority
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    } label: {
                                        Label {
                                            Text(priority.title)
                                        } icon: {
                                            PriorityIcon(priority: priority)
                                                .frame(width: 16, height: 16)
                                        }
                                    }
                                }
                            } label: {
                                TopButtonChip(
                                    title: schedule.priority.title,
                                    imageName: "",
                                    isSystem: true) {
                                        PriorityIcon(priority: schedule.priority)
                                    }
                            }
                            
                            Menu { // status
                                ForEach(Status.allCases, id: \.self) { status in
                                    Button {
                                        do {
                                            try appData.setStatus(schedule: schedule, to: status)
                                            self.schedule.status = status
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    } label: {
                                        Text(status.title)
                                        Image(systemName: status.systemName)
                                    }
                                }
                            } label: {
                                TopButtonChip(
                                    title: schedule.status.title,
                                    imageName: schedule.status.systemName,
                                    isSystem: true) {
                                        
                                    }
                                    .setImageColor(schedule.status.imageColor)
                                    .imageBold()
                            }
                            
                            LabelSheetButton(appData: $appData, schedule: schedule) { labels in
                                do {
                                    try appData.setLabel(schedule: schedule, labels: labels)
                                    self.schedule.labels = labels
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                let labels = schedule.labels
                                if let firstLabel = labels.first {
                                    TopButtonChip(
                                        title: labels.count == 1 ? firstLabel.content : "\(firstLabel.content) +\(labels.count - 1)",
                                        imageName: "",
                                        isSystem: true
                                    ) {
                                        
                                    }
                                } else {
                                    TopButtonChip(
                                        title: "Labels",
                                        imageName: "tag",
                                        isSystem: true) {
                                            
                                        }
                                }
                            }
                            
                            ColorSheetButton { color in
                                do {
                                    try appData.changeColor(schedule: schedule, to: color)
                                    self.schedule.markColor = color
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                TopButtonChip(
                                    title: schedule.markColor.title,
                                    imageName: "circle.fill",
                                    isSystem: true) {
                                    }
                                    .setImageColor(schedule.markColor.color)
                            }
                            
                            if var project = project {
                                let members = appData.clients.filter { project.clientIds.contains($0.id) }
                                AddMemberSheetButton(appData: $appData, members: members) { newMembers in
                                    do {
                                        try appData.changeProjectMembers(project: project, to: newMembers)
                                        project.clientIds = newMembers.map { $0.id }
                                        self.schedule = project
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                } label: {
                                    let memberIds = project.clientIds
                                    let members = appData.clients.filter { memberIds.contains($0.id) }
                                    if let firstMember = members.first {
                                        TopButtonChip(
                                            title: members.count == 1 ? firstMember.fullName : "\(firstMember.fullName) +\(members.count - 1)",
                                            imageName: "",
                                            isSystem: true
                                        ) {
                                            CircleNames(views:
                                                            members.map {
                                                CircleName(markColor: $0.markColor, text: $0.fullName)
                                                    .setCircleSize(16)
                                            }
                                            )
                                            
                                        }
                                        .fixedWidth()
                                    } else {
                                        TopButtonChip(
                                            title: "Members",
                                            imageName: "person.fill",
                                            isSystem: true) {
                                                
                                            }
                                    }
                                }
                            }
                            
                            let dueDate = schedule.hasDeadline ?
                            "Due date : " + schedule.dueDate.toString() :
                            "No due date"
                            TopButtonChip(
                                title: dueDate,
                                imageName: "",
                                isSystem: true) {
                                    if self.schedule.hasDeadline {
                                        Button {
                                            do {
                                                try appData.changeDueDate(schedule: schedule, !self.schedule.hasDeadline, to: schedule.dueDate)
                                                self.schedule.hasDeadline = !self.schedule.hasDeadline
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        } label: {
                                            Image(systemName: schedule.hasDeadline ? "checkmark.square" : "square")
                                                .font(.caption)
                                                .foregroundStyle(.black)
                                        }
                                    }
                                }
                                .overlay {
                                    DatePicker(selection: $schedule.dueDate, displayedComponents: .date) {}
                                        .labelsHidden()
                                        .colorMultiply(.clear)       // <<< here
                                }
                                .onChange(of: schedule.dueDate, perform: { value in
                                    do {
                                        try appData.changeDueDate(schedule: schedule, true, to: schedule.dueDate)
                                        self.schedule.hasDeadline = true
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                })
                        }
                        .hideDivider()
                    }
                    
                    VStack(alignment: .leading) {
                        ZStack {
                            Text(schedule.description)
                                .padding([.leading, .trailing], 5)
                                .padding([.top, .bottom], 8)
                                .opacity(0)
                            
                            TextEditor(text: $schedule.description)
                                .onDisappear {
                                    if schedule.name != "" {
                                        do {
                                            try appData.changeName(schedule: schedule, to: schedule.name)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    do {
                                        try appData.changeDescription(schedule: schedule, to: schedule.description)
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                                .toolbar {
                                    ToolbarItemGroup(placement: .keyboard) {
                                        Spacer()
                                        
                                        Button("Done") {
                                            hideKeyboard()
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    
                    Group {
                        if var task, let superior = appData.getSuperior(of: task) {
                            BlockDivider()
                            
                            HStack(spacing: 0) {
                                Text("Sub task of ")
                                    .font(.headline)
                                SelectSuperiorSheetButton(appData: $appData, task: task) { superior in
                                    do {
                                        try appData.changeSuperior(task: task, to: superior)
                                        task.superiorId = superior.id
                                        self.schedule = task
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                } label: {
                                    Text(superior.name)
                                        .font(.headline)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScheduleItemView(schedule: superior, appData: $appData)
                                .padding(.bottom)
                        } else if var task {
                            BlockDivider()
                            
                            HStack(spacing: 0) {
                                Text("Sub task of ")
                                    .font(.headline)
                                SelectSuperiorSheetButton(appData: $appData, task: task) { superior in
                                    do {
                                        try appData.changeSuperior(task: task, to: superior)
                                        task.superiorId = superior.id
                                        self.schedule = task
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                } label: {
                                    Text("Select Superior")
                                        .font(.headline)
                                }
                            }
                            .padding()
                        }
                    }
                    BlockDivider()
                    if let task, task.superiorId == nil {
                        EmptyView()
                    } else {
                        VStack(alignment: .leading) {
                            let tasks = appData.tasks.filter({ schedule.taskIds.contains($0.id) })
                            let notDoneTasks = tasks.filter({ self.shouldShowDone ? true : $0.status != .done && $0.status != .canceled })
                            HStack {
                                TaskProgressBar(tasks: tasks)
                                Spacer()
                                Button {
                                    withAnimation(.spring) {
                                        self.isTaskFolded = !self.isTaskFolded
                                    }
                                } label: {
                                    Image(systemName: self.isTaskFolded ? "chevron.down" : "chevron.up")
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    NavigationLink {
                                        TaskAddView(superior: schedule, appData: $appData) { newTask in
                                            self.schedule.taskIds.append(newTask.id)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: "New Sub task",
                                            imageName: "plus",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    }
                                    
                                    SubTaskSheetButton(appData: $appData, schedule: schedule) { taskIds in
                                        do {
                                            try appData.changeSubTasks(schedule: schedule, with: taskIds)
                                            self.schedule.taskIds = taskIds
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: "Add Sub task",
                                            imageName: "list.bullet",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    }
                                    
                                    Button {
                                        self.shouldShowDone = !self.shouldShowDone
                                    } label: {
                                        TopButtonChip(
                                            title: "Hide Done",
                                            imageName: !self.shouldShowDone ? "checkmark.square" : "square",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            
                            if !self.isTaskFolded {
                                VStack(spacing: 0) {
                                    ForEach(notDoneTasks, id: \.self) { task in
                                        ScheduleItemView(schedule: task, appData: $appData)
                                    }
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        BlockDivider()
                    }
                    if let project {
                        VStack(alignment: .leading) {
                            Text("\(project.clientIds.count) Members Included")
                                .font(.headline)
                                .bold()
                                .padding(.horizontal)
                                .padding(.top)
                            let clients = appData.clients.filter({
                                print($0.id)
                                print(project.clientIds)
                                return project.clientIds.contains($0.id) })
                            VStack(spacing: 0) {
                                ForEach(clients, id: \.self) { client in
                                    ClientItemView(appData: $appData, client: client)
                                        .padding()
                                    Divider()
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        BlockDivider()
                    }
                    AppointmentView(schedule: schedule, appData: $appData)
                    
                    BlockDivider()
                    
                    MomentView(appData: $appData, schedule: schedule)
                    
                    BlockDivider()
                    
                    DeleteButton {
                        do {
                            try appData.delete(schedule: schedule)
                        } catch {
                            print(error.localizedDescription)
                        }
                    } secondAction: {
                        do {
                            try appData.delete(schedule: schedule, shouldDeleteSubTasks: true)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .padding()
                }
            }
#if !DEBUG
            GADBanner().frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
#endif
        }
        .task {
            if let project {
                if let _project = appData.projects.first(where: { $0.id == project.id }) {
                    if project != _project {
                        self.schedule = _project
                    }
                }
            } else if let task {
                if let _task = appData.tasks.first(where: { $0.id == task.id }) {
                    if task != _task {
                        self.schedule = _task
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

#Preview {
    ContentView()
}

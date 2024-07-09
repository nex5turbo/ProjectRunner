//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ProjectDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var project: TProject
    @Binding var appData: AppData
    @AppStorage("isTaskFolded") private var isTaskFolded: Bool = false
    @State private var isDeleteConfirm: Bool = false
    @AppStorage("showDone") private var shouldShowDone = false
    
    init(project: TProject, appData: Binding<AppData>) {
        self._project = State(initialValue: project)
        self._appData = appData
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 0) {
                    TextField("", text: $project.name, prompt: Text("Project title..."))
                        .font(.title2)
                        .padding(.horizontal)
                        .bold()
                    NavigationTopItems {
                        Menu { // priority
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Button {
                                    do {
                                        try appData.setProjectPriority(project: project, to: priority)
                                        self.project.priority = priority
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
                                title: project.priority.title,
                                imageName: "",
                                isSystem: true) {
                                    PriorityIcon(priority: project.priority)
                                }
                        }
                        
                        Menu { // status
                            ForEach(Status.allCases, id: \.self) { status in
                                Button {
                                    do {
                                        try appData.setProjectStatus(project: project, to: status)
                                        self.project.status = status
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                } label: {
                                    Text(status.title)
                                }
                            }
                        } label: {
                            TopButtonChip(
                                title: project.status.title,
                                imageName: "",
                                isSystem: true) {
                                    
                                }
                        }
                        
                        LabelSheetButton(appData: $appData, schedule: project) { labels in
                            do {
                                try appData.setLabel(schedule: project, labels: labels)
                                self.project.labels = labels
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            let labels = project.labels
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
                                try appData.changeColor(schedule: project, to: color)
                                self.project.markColor = color
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            TopButtonChip(
                                title: project.markColor.title,
                                imageName: "circle.fill",
                                isSystem: true) {
                                }
                                .setImageColor(project.markColor.color)
                        }
                        
                        let members = appData.clients.filter { project.clientIds.contains($0.id) }
                        AddMemberSheetButton(appData: $appData, members: members) { newMembers in
                            do {
                                try appData.changeProjectMembers(project: project, to: newMembers)
                                self.project.clientIds = newMembers.map { $0.id }
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
                        
                        TopButtonChip(
                            title: project.dueDate.toString(),
                            imageName: "",
                            isSystem: true) {
                                
                            }
                            .overlay {
                                DatePicker(selection: $project.dueDate, displayedComponents: .date) {}
                                    .labelsHidden()
                                    .colorMultiply(.clear)       // <<< here
                            }
                            .onChange(of: project.dueDate, perform: { value in
                                do {
                                    try appData.changeDueDate(schedule: project, project.hasDeadline, to: project.dueDate)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            })
                    }
                    .hideDivider()
                }
                
                VStack(alignment: .leading) {
                    ZStack {
                        Text(project.description)
                            .padding([.leading, .trailing], 5)
                            .padding([.top, .bottom], 8)
                            .opacity(0)
                        
                        TextEditor(text: $project.description)
                            .onDisappear {
                                if project.name != "" {
                                    do {
                                        try appData.changeName(schedule: project, to: project.name)
                                    } catch {
                                        print(error.localizedDescription)
                                    }
                                }
                                do {
                                    try appData.changeDescription(schedule: project, to: project.description)
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
                
                BlockDivider()
                VStack(alignment: .leading) {
                    let tasks = appData.tasks.filter({ project.taskIds.contains($0.id) })
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
                                TaskAddView(superior: project, appData: $appData) { newTask in
                                    self.project.taskIds.append(newTask.id)
                                }
                            } label: {
                                TopButtonChip(
                                    title: "New Sub task",
                                    imageName: "plus",
                                    isSystem: true
                                ) {
                                    
                                }
                            }
                            
                            SubTaskSheetButton(appData: $appData, schedule: project) { taskIds in
                                do {
                                    try appData.changeSubTasks(schedule: project, with: taskIds)
                                    self.project.taskIds = taskIds
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
                                    .navigatable()
                            }
                        }
                    }
                }
                .padding(.bottom)
                
                BlockDivider()
                //                디자인 뽑히기 전까지 보류
                //                VStack(alignment: .leading) {
                //                    Text("Timeline")
                //                        .font(.headline)
                //                        .padding(.horizontal)
                //                        .padding(.top)
                //
                //                    AnimatedTimeline(schedule: project, appData: $appData)
                //                        .padding()
                //                }
                
                
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
                
                AppointmentView(schedule: project, appData: $appData)
                
                BlockDivider()
                
                MomentView(appData: $appData, schedule: project)
                
                BlockDivider()
                
                DeleteButton {
                    do {
                        try appData.deleteProject(project: project)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .padding()
            }
        }
        .task {
            if let _project = appData.projects.first(where: { $0.id == project.id }) {
                if project != _project {
                    self.project = _project
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

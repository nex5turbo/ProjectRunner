//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI
import GoogleMobileAds

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var task: TTask
    @Binding var appData: AppData

    @State private var isDeleteConfirm: Bool = false
    
    @AppStorage("showDone") var shouldShowDone: Bool = false
    @AppStorage("isTaskFolded") private var isTaskFolded: Bool = false
    
    init(task: TTask, appData: Binding<AppData>) {
        self._task = State(initialValue: task)
        self._appData = appData
    }
    var body: some View {
        VStack(spacing: 0){
            ScrollView {
                VStack(alignment: HorizontalAlignment.leading) {
                    VStack(alignment: .leading, spacing: 0) {
                        TextField("", text: $task.name, prompt: Text("Task title..."))
                            .font(.title2)
                            .padding(.horizontal)
                            .bold()
                        NavigationTopItems {
                            Menu { // priority
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Button {
                                        do {
                                            try appData.setTaskPriority(task: task, to: priority)
                                            self.task.priority = priority
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
                                    title: task.priority.title,
                                    imageName: "",
                                    isSystem: true) {
                                        PriorityIcon(priority: task.priority)
                                    }
                            }
                            
                            Menu { // status
                                ForEach(Status.allCases, id: \.self) { status in
                                    Button {
                                        do {
                                            try appData.setTaskStatus(task: task, to: status)
                                            self.task.status = status
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    } label: {
                                        Text(status.title)
                                    }
                                }
                            } label: {
                                TopButtonChip(
                                    title: task.status.title,
                                    imageName: "",
                                    isSystem: true) {
                                        
                                    }
                            }
                            
                            
                            LabelSheetButton(appData: $appData, schedule: task) { labels in
                                do {
                                    try appData.setLabel(schedule: task, labels: labels)
                                    self.task.labels = labels
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                let labels = task.labels
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
                                    try appData.changeColor(schedule: task, to: color)
                                    self.task.markColor = color
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                TopButtonChip(
                                    title: task.markColor.title,
                                    imageName: "circle.fill",
                                    isSystem: true) {
                                    }
                                    .setImageColor(task.markColor.color)
                            }
                        }
                        .hideDivider()
                    }
                    VStack(alignment: .leading) {
                        ZStack {
                            Text(task.description)
                                .padding([.leading, .trailing], 5)
                                .padding([.top, .bottom], 8)
                                .opacity(0)
                            
                            TextEditor(text: $task.description)
                                .onDisappear {
                                    if task.name != "" {
                                        do {
                                            try appData.changeName(schedule: task, to: task.name)
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                    do {
                                        try appData.changeDescription(schedule: task, to: task.description)
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
                        if let superior = appData.getSuperior(of: task) {
                            BlockDivider()
                            
                            HStack(spacing: 0) {
                                Text("Sub task of ")
                                    .font(.headline)
                                SelectSuperiorSheetButton(appData: $appData, task: task) { superior in
                                    do {
                                        try appData.changeSuperior(task: task, to: superior)
                                        self.task.superiorId = superior.id
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
                        } else {
                            BlockDivider()
                            
                            HStack(spacing: 0) {
                                Text("Sub task of ")
                                    .font(.headline)
                                SelectSuperiorSheetButton(appData: $appData, task: task) { superior in
                                    do {
                                        try appData.changeSuperior(task: task, to: superior)
                                        self.task.superiorId = superior.id
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
                    
                    if task.superiorId != nil {
                        VStack(alignment: .leading) {
                            let tasks = appData.tasks.filter({ task.taskIds.contains($0.id) })
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
                                        TaskAddView(superior: task, appData: $appData) { newTask in
                                            self.task.taskIds.append(newTask.id)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: "New Sub task",
                                            imageName: "plus",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    }
                                    
                                    SubTaskSheetButton(appData: $appData, schedule: task) { taskIds in
                                        do {
                                            try appData.changeSubTasks(schedule: task, with: taskIds)
                                            self.task.taskIds = taskIds
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
                    }
                    
                    BlockDivider()
                    
                    //                디자인 뽑히기 전까지 보류
                    //                VStack(alignment: .leading) {
                    //                    Text("Timeline")
                    //                        .font(.headline)
                    //                        .padding(.horizontal)
                    //                        .padding(.top)
                    //
                    //                    AnimatedTimeline(schedule: task, appData: $appData)
                    //                        .padding()
                    //                }
                    
                    AppointmentView(schedule: task, appData: $appData)
                    
                    
                    BlockDivider()
                    
                    MomentView(appData: $appData, schedule: task)
                    
                    BlockDivider()
                    
                    DeleteButton {
                        do {
                            try appData.deleteTask(task: task)
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    .padding()
                }
            }
            GADBanner().frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)
        }
        .task {
            if let _task = appData.tasks.first(where: { $0.id == task.id }) {
                if task != _task {
                    self.task = _task
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

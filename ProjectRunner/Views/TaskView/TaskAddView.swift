//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import YPImagePicker
import SwiftUI

struct TaskAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var appData: AppData
    @State private var isFileConfirmPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var isFilePickerPresented: Bool = false
    
    let onSaved: (TTask) -> Void
    
    init(task: TTask, appData: Binding<AppData>) {
        self._newTask = State(initialValue: task)
        self._appData = appData
        self.isEditing = true
        self.onSaved = { _ in }
    }
    
    init(appData: Binding<AppData>) {
        self._appData = appData
        self.isEditing = false
        self._newTask = State(initialValue: TTask.emptyTask())
        self.onSaved = { _ in }
    }
    
    init(superior: Schedulable, appData: Binding<AppData>, _ onSaved: @escaping (TTask) -> Void) {
        self._appData = appData
        self.isEditing = false
        var newTask = TTask.emptyTask()
        newTask.superiorId = superior.id
        newTask.markColor = superior.markColor
        self._newTask = State(initialValue: newTask)
        self.onSaved = onSaved
    }
    
    init(dueDate: Date, appData: Binding<AppData>) {
        self._appData = appData
        self.isEditing = false
        var newTask = TTask.emptyTask()
        newTask.hasDeadline = true
        newTask.dueDate = dueDate
        self._newTask = State(initialValue: newTask)
        self.onSaved = { _ in }
    }
    
    let isEditing: Bool
    private var navTitle: String {
        isEditing ? "Edit Task" : "New Task"
    }
    @State private var newTask: TTask

    private var isDuplicated: Bool {
        return appData.tasks.contains { $0.name == newTask.name && $0.id != newTask.id }
    }
    private var isDateAvailable: Bool {
        newTask.createdAt <= newTask.dueDate.endOfDayDate()
    }
    private var canSave: Bool {
        newTask.name != "" &&
        isDateAvailable &&
        !isDuplicated
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    TextField("Name", text: $newTask.name, prompt: Text("Task title"))
                        .font(.title3)
                        .bold()
                        .padding(.horizontal, 4)
                        .padding(.top)
                    if isDuplicated {
                        Text("* Duplicated name")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                    ZStack {
                        TextEditor(text: $newTask.description)
                        
                        if self.newTask.description == "" {
                            VStack {
                                HStack {
                                    Text("Add description...")
                                        .foregroundStyle(.gray)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 4)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .allowsHitTesting(false)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    
                }
                .padding()
                
                ScrollView(.horizontal) {
                    HStack {
                        SelectSuperiorSheetButton(appData: $appData, task: newTask) { superior in
                            self.newTask.superiorId = superior.id
                        } label: {
                            let title: String = {
                                if let selectedSuperiorId = newTask.superiorId,
                                   let superior = appData.getSuperior(of: selectedSuperiorId) {
                                    return superior.name
                                } else {
                                    return "Select Project"
                                }
                            }()
                            TopButtonChip(
                                title: title,
                                imageName: "",
                                isSystem: true
                            ) {
                                
                            }
                        }
                        
                        Menu {
                            ForEach(Status.allCases, id: \.self) { status in
                                Button {
                                    self.newTask.status = status
                                } label: {
                                    Text(status.title)
                                    Image(systemName: status.systemName)
                                }
                                
                            }
                        } label: {
                            TopButtonChip(
                                title: newTask.status.title,
                                imageName: newTask.status.systemName,
                                isSystem: true) {
                                    
                                }
                                .setImageColor(newTask.status.imageColor)
                                .imageBold()
                        }
                        
                        Menu {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Button {
                                    self.newTask.priority = priority
                                } label: {
                                    Text(priority.title)
                                }
                                
                            }
                        } label: {
                            TopButtonChip(
                                title: newTask.priority.title,
                                imageName: "",
                                isSystem: true
                            ) {
                                PriorityIcon(priority: newTask.priority)
                            }
                        }
                        
                        LabelSheetButton(appData: $appData, schedule: newTask) { labels in
                            self.newTask.labels = labels
                        } label: {
                            if self.newTask.labels.isEmpty {
                                TopButtonChip(title: "Label", imageName: "tag", isSystem: true) {
                                    
                                }
                            } else {
                                TopButtonChip(title: "\(self.newTask.labels.first!.content)\(self.newTask.labels.count == 1 ? "" : " +\(self.newTask.labels.count - 1)")", imageName: "", isSystem: true) {
                                }
                            }
                        }
                        
                        ColorSheetButton { color in
                            self.newTask.markColor = color
                        } label: {
                            TopButtonChip(
                                title: newTask.markColor.title,
                                imageName: "circle.fill",
                                isSystem: true) {
                                }
                                .setImageColor(newTask.markColor.color)
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.never)
                
                Toggle(isOn: $newTask.hasDeadline) {
                    sectionText("Set due date")
                }
                .padding()

                if newTask.hasDeadline {
                    DatePicker("Due Date", selection: $newTask.dueDate, displayedComponents: .date)
                        .foregroundStyle(isDateAvailable ? .black : .red)
                        .padding()
                        .disabled(!newTask.hasDeadline)
                    
                    if !isDateAvailable {
                        Text("Due date must be later than start date!")
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                }
#if DEBUG
                
                HStack {
                    sectionText("References")
                    
                    Spacer()
                    
                    PremiumButton(reachedLimit: true, reason: "Subscribe and attach files to your schedules!", action: {
                        self.isFileConfirmPresented.toggle()
                    }, label: {
                        HStack {
                            Text("+")
                                .padding(8)
                                .foregroundStyle(.gray)
                                .background(.gray.opacity(0.2))
                                .clipShape(Circle())
                                .clipped()
                        }
                        .font(.headline)
                    })
                    .confirmationDialog("", isPresented: $isFileConfirmPresented) {
                        Button("Files") {
                            self.isFilePickerPresented.toggle()
                        }
                        
                        Button("Images") {
                            self.isImagePickerPresented.toggle()
                        }
                    }
                    .sheet(isPresented: $isFilePickerPresented) {
                        FilePicker { files in
                            newTask.files.append(contentsOf: files)
                        }
                    }
                    .sheet(isPresented: $isImagePickerPresented) {
                        ImagePicker { files in
                            newTask.files.append(contentsOf: files)
                        }
                    }
                }
                .padding(.horizontal)
                
                FileList(fileAttachable: newTask) { file in
                    do {
                        try file.delete()
                        newTask.files.removeAll(where: { $0 == file })
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
#endif
            }
        }
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem {
                PremiumButton(
                    reachedLimit: appData.hasReachedLimit(projectId: newTask.superiorId), 
                    reason: .createMoreTasks(appData.projects.first(where: { $0.id == newTask.superiorId })?.name ?? "Todo")) {
                    self.newTask.dueDate = self.newTask.dueDate.endOfDayDate()
                    do {
                        try self.appData.addTask(task: newTask)
                        onSaved(newTask)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Text("Save")
                }
                .disabled(!canSave)
            }
        }
    }
    
    @ViewBuilder func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.headline)
    }
}

#Preview {
    ContentView()
}

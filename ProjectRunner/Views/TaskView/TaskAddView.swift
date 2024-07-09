//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct TaskAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var appData: AppData
    
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
    
    let isEditing: Bool
    private var navTitle: String {
        isEditing ? "Edit Task" : "New Task"
    }
    @State private var newTask: TTask
    @State private var isLabelAddSheetPresented: Bool = false
    @State private var isSuperiorSheetPresented: Bool = false
    private var isDuplicated: Bool {
        return appData.tasks.contains { $0.name == newTask.name && $0.id != newTask.id }
    }
    private var isDateAvailable: Bool {
        newTask.startDate <= newTask.dueDate
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
                        Button {
                            self.isSuperiorSheetPresented = true
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
                        .sheet(isPresented: $isSuperiorSheetPresented) {
                            SelectSuperiorSheet(task: newTask, appData: $appData) { superior in
                                self.newTask.superiorId = superior.id
                            }
                        }
                        
                        Menu {
                            ForEach(Status.allCases, id: \.self) { status in
                                Button {
                                    self.newTask.status = status
                                } label: {
                                    Text(status.title)
                                }
                                
                            }
                        } label: {
                            TopButtonChip(
                                title: newTask.status.title,
                                imageName: "",
                                isSystem: true
                            ) {
                                
                            }
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
                        
                        Button {
                            self.isLabelAddSheetPresented = true
                        } label: {
                            if self.newTask.labels.isEmpty {
                                TopButtonChip(title: "Label", imageName: "tag", isSystem: true) {
                                    
                                }
                            } else {
                                TopButtonChip(title: "\(self.newTask.labels.first!.content)\(self.newTask.labels.count == 1 ? "" : " +\(self.newTask.labels.count - 1)")", imageName: "", isSystem: true) {
                                    
                                }
                            }
                        }
                        .sheet(isPresented: $isLabelAddSheetPresented) {
                            LabelSheet(schedule: newTask, appData: $appData) { labels in
                                self.newTask.labels = labels
                            }
                        }
                        
                        Menu {
                            ForEach(MarkColor.allCases, id: \.self) { color in
                                Button {
                                    self.newTask.markColor = color
                                } label: {
                                    Label {
                                        Text(color.title)
                                    } icon: {
                                        Image(systemName: "circle.fill")
                                            .renderingMode(.template)
                                            .foregroundStyle(color.color)
                                    }
                                    
                                }
                            }
                        } label: {
                            TopButtonChip(
                                title: newTask.markColor.title,
                                imageName: "circle.fill",
                                isSystem: true
                            ) {
                                
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
                
                DatePicker("Start Date", selection: $newTask.startDate, displayedComponents: .date)
                    .padding()
                if newTask.hasDeadline {
                    DatePicker("Due Date", selection: $newTask.dueDate, displayedComponents: .date)
                        .foregroundStyle(isDateAvailable ? .black : .red)
                        .padding()
                        .disabled(!newTask.hasDeadline)
                    
                    if !isDateAvailable {
                        Text("Due date must be later than start date!")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .navigationTitle(navTitle)
        .toolbar {
            ToolbarItem {
                Button("Save") {
                    self.newTask.startDate = self.newTask.startDate.startOfDayDate()
                    self.newTask.dueDate = self.newTask.dueDate.endOfDayDate()
                    do {
                        try self.appData.addTask(task: newTask)
                        onSaved(newTask)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
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

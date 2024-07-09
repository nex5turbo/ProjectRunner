//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ProjectAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var appData: AppData
    @State private var isLabelAddSheetPresented: Bool = false
    
    init(project: TProject, appData: Binding<AppData>) {
        self._newProject = State(initialValue: project)
        
        self._appData = appData
        self.isEditing = true
    }
    init(appData: Binding<AppData>) {
        self._newProject = State(initialValue: TProject.empty())
        self._appData = appData
        self.isEditing = false
    }
    let isEditing: Bool
    private var navTitle: String {
        isEditing ? "Edit Project" : "New Project"
    }
    @State private var newProject: TProject
    private var isDateAvailable: Bool {
        newProject.startDate <= newProject.dueDate
    }
    private var isDuplicated: Bool {
        return appData.projects.contains { $0.name == newProject.name && $0.id != newProject.id }
    }
    private var canSave: Bool {
        newProject.name != "" &&
        isDateAvailable &&
        !isDuplicated
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    TextField("Name", text: $newProject.name, prompt: Text("Project title"))
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
                        TextEditor(text: $newProject.description)
                        
                        if self.newProject.description == "" {
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
                        Menu {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Button {
                                    self.newProject.priority = priority
                                } label: {
                                    Text(priority.title)
                                }
                                
                            }
                        } label: {
                            TopButtonChip(
                                title: newProject.priority.title,
                                imageName: "",
                                isSystem: true
                            ) {
                                PriorityIcon(priority: newProject.priority)
                            }
                        }
                        
                        Menu {
                            ForEach(Status.allCases, id: \.self) { status in
                                Button {
                                    self.newProject.status = status
                                } label: {
                                    Text(status.title)
                                }
                            }
                        } label: {
                            TopButtonChip(
                                title: newProject.status.title,
                                imageName: "",
                                isSystem: true
                            ) {
                                
                            }
                        }
                        
                        Menu {
                            ForEach(appData.clients, id: \.self) { client in
                                Button {
                                    if self.newProject.clientIds.contains(client.id) {
                                        self.newProject.clientIds.removeAll(where: { $0 == client.id })
                                    } else {
                                        self.newProject.clientIds.append(client.id)
                                    }
                                } label: {
                                    Label(client.fullName, systemImage: self.newProject.clientIds.contains(client.id) ? "checkmark" : "")
                                        .foregroundStyle(self.newProject.clientIds.contains(client.id) ? .teal : .black)
                                }
                            }
                        } label: {
                            let selectedClients = appData.clients.filter { newProject.clientIds.contains($0.id) }
                            ZStack {
                                if selectedClients.isEmpty {
                                    TopButtonChip(
                                        title: "Tap to select members",
                                        imageName: "person.fill",
                                        isSystem: true
                                    ) {
                                        
                                    }
                                } else {
                                    if selectedClients.count == 1 {
                                        TopButtonChip(
                                            title: selectedClients.first!.fullName,
                                            imageName: "person.fill",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    } else {
                                        TopButtonChip(
                                            title: "\(selectedClients.first!.fullName) +\(selectedClients.count - 1)",
                                            imageName: "person.fill",
                                            isSystem: true
                                        ) {
                                            
                                        }
                                    }
                                }
                            }
                        }
                        
                        Menu {
                            ForEach(MarkColor.allCases, id: \.self) { color in
                                Button {
                                    self.newProject.markColor = color
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
                                title: newProject.markColor.title,
                                imageName: "circle.fill",
                                isSystem: true
                            ) {
                                
                            }
                            .setImageColor(newProject.markColor.color)
                        }
                        
                        Button {
                            self.isLabelAddSheetPresented = true
                        } label: {
                            if self.newProject.labels.isEmpty {
                                TopButtonChip(title: "Label", imageName: "tag", isSystem: true) {
                                    
                                }
                            } else {
                                TopButtonChip(title: "\(self.newProject.labels.first!.content)\(self.newProject.labels.count == 1 ? "" : " +\(self.newProject.labels.count - 1)")", imageName: "", isSystem: true) {
                                    
                                }
                            }
                        }
                        .sheet(isPresented: $isLabelAddSheetPresented) {
                            LabelSheet(schedule: newProject, appData: $appData) { labels in
                                self.newProject.labels = labels
                            }
                        }
                    }
                    .padding()
                }
                .scrollIndicators(.never)
                
                Toggle(isOn: $newProject.hasDeadline) {
                    sectionText("Set Due date")
                }
                .padding(.horizontal)
                
                DatePicker("Start Date", selection: $newProject.startDate, displayedComponents: .date)
                    .padding()
                if newProject.hasDeadline {
                    DatePicker("Due Date", selection: $newProject.dueDate, displayedComponents: .date)
                        .foregroundStyle(isDateAvailable ? .black : .red)
                        .padding()
                        .disabled(!newProject.hasDeadline)
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
                    self.newProject.startDate = self.newProject.startDate.startOfDayDate()
                    self.newProject.dueDate = self.newProject.dueDate.endOfDayDate()
                    do {
                        try self.appData.addProject(project: newProject)
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    dismiss()
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

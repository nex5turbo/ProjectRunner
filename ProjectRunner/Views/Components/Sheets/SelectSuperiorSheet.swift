//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/8/24.
//

import SwiftUI

struct SelectSuperiorSheet: View {
    @Environment(\.dismiss) var dismiss
    let task: TTask
    @Binding var appData: AppData
    let onSelect: (Schedulable) -> Void

    var body: some View {
        List {
            let filteredProjects = appData.projects.filter { $0.status != .done && $0.status != .canceled }
            Section {
                ForEach(filteredProjects, id: \.self) { project in
                    let isSelectedOne = project.id == task.superiorId
                    Text(project.name)
                        .foregroundStyle(isSelectedOne ? .blue : .black)
                        .onTapGesture {
                            guard !isSelectedOne else {
                                return
                            }
                            onSelect(project)
                            dismiss()
                        }
                }
            } header: {
                HStack {
                    Text("Projects")
                        .foregroundStyle(.black)
                    Text("\(filteredProjects.count)")
                        .foregroundStyle(.gray)
                }
                .font(.title3)
            }
            
            let filteredTasks = getFilteredTasks(currentTask: task, tasks: appData.tasks.filter { $0.status != .done && $0.status != .canceled && $0.superiorId != nil })
            Section {
                ForEach(filteredTasks, id: \.self) { stask in
                    if task.id != stask.id {
                        let isSelectedOne = stask.id == task.superiorId
                        Text(stask.name)
                            .foregroundStyle(isSelectedOne ? .blue : .black)
                            .onTapGesture {
                                guard !isSelectedOne else {
                                    return
                                }
                                onSelect(stask)
                                dismiss()
                            }
                    }
                }
            } header: {
                HStack {
                    Text("Tasks")
                        .foregroundStyle(.black)
                    Text("\(filteredTasks.count)")
                        .foregroundStyle(.gray)
                }
                .font(.title3)
            }
        }
    }
    
    func getFilteredTasks(currentTask: TTask, tasks: [TTask]) -> [TTask] {
        let subTaskIds = currentTask.taskIds
        guard !subTaskIds.isEmpty else {
            return tasks
        }
        var tasks = tasks
        subTaskIds.forEach { id in
            tasks.removeAll(where: { $0.id == id })
            guard let subTask = appData.tasks.first(where: { $0.id == id }) else {
                return
            }
            tasks = getFilteredTasks(currentTask: subTask, tasks: tasks)
        }
        return tasks
    }
}

#Preview {
    ContentView()
}

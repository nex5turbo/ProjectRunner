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
            
            let filteredTasks = appData.tasks.filter { $0.status != .done && $0.status != .canceled }
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
}

#Preview {
    ContentView()
}

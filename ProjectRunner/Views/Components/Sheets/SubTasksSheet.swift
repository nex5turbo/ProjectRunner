//
//  SubTasksSheet.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct SubTasksSheet: View {
    @State private var schedule: Schedulable
    @Binding private var appData: AppData
    let onSelect: ([String]) -> Void
    
    init(schedule: Schedulable, appData: Binding<AppData>, onSelect: @escaping ([String]) -> Void) {
        self._schedule = State(initialValue: schedule)
        self._appData = appData
        self.onSelect = onSelect
    }

    var body: some View {
        List {
            let filteredTasks = getFilteredTasks()
            // 자기 부모도 가져오면 안됨 부모의 부모도 안됨
            Section {
                ForEach(filteredTasks, id: \.self) { stask in
                    if schedule.id != stask.id {
                        let isSelectedOne = schedule.taskIds.contains(stask.id)
                        Text(stask.name)
                            .foregroundStyle(isSelectedOne ? .blue : .black)
                            .onTapGesture {
                                if schedule.taskIds.contains(where: { $0 == stask.id }) {
                                    schedule.taskIds.removeAll(where: { $0 == stask.id })
                                } else {
                                    schedule.taskIds.append(stask.id)
                                }
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
        .onDisappear {
            onSelect(schedule.taskIds)
        }
    }
    
    func getFilteredTasks() -> [TTask] {
        var filtered = appData.tasks.filter { $0.status != .done && $0.status != .canceled }
        guard let task = schedule as? TTask, var superiorId = task.superiorId else {
            return filtered
        }
        while let nextTask = appData.tasks.first(where: { $0.id == superiorId }) {
            filtered.removeAll(where: { $0.id == nextTask.id })
            guard let nextId = nextTask.superiorId else {
                break
            }
            superiorId = nextId
        }
        return filtered
    }
}

#Preview {
    ContentView()
}

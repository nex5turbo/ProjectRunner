//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 7/5/24.
//

import SwiftUI

struct ScheduleItemView: View {
    let schedule: Schedulable
    @Binding var appData: AppData
    @Binding var selectedSchedules: [Schedulable]
    init(schedule: Schedulable, appData: Binding<AppData>) {
        self.schedule = schedule
        self._appData = appData
        self._selectedSchedules = .constant([])
    }
    
    @State private var titleTextHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    @State private var sideButtonWidth: CGFloat = 1
    
    private var isSwipeEnabled: Bool = false
    private var isSelected: Bool {
        self.selectedSchedules.contains(where: { $0.id == schedule.id })
    }
    
    var offset: CGFloat {
        isSelected ? sideButtonWidth + dragOffset : dragOffset
    }
    
    var body: some View {
        NavigationLink {
            DetailView(schedule: schedule, appData: $appData)
        } label: {
            content()
        }
        .foregroundStyle(Color.black)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(.white)
        .overlay {
            RoundedRectangle(cornerRadius: 0)
                .stroke(.gray, lineWidth: 0.2)
        }
        .overlay {
            ZStack {
                HStack {
                    schedule.markColor.color.frame(width: (isSelected ? 0 : 8) + max(0.0, offset))
                    Spacer()
                }
                HStack {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation {
                                self.selectedSchedules.removeAll(where: { $0.id == schedule.id })
                            }
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .foregroundStyle(schedule.markColor.textColor)
                    }
                    .padding(.horizontal)
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear.task {
                                self.sideButtonWidth = max(1.0, proxy.size.width)
                            }
                        }
                    }
                    .offset(x: -sideButtonWidth + offset)
                    .opacity(offset / self.sideButtonWidth)
                    
                    Spacer()
                }
            }
        }
        .animation(.spring, value: dragOffset == 0.0)
        .dragGesture(onUpdate: { value in
            guard isSwipeEnabled else {
                return
            }
            self.dragOffset = value.translation.width
        }, onEnded: { value in
            guard isSwipeEnabled else {
                return
            }
            if value.predictedEndTranslation.width >= self.sideButtonWidth {
                if !self.isSelected {
                    self.selectedSchedules.append(schedule)
                }
            } else {
                if self.isSelected {
                    self.selectedSchedules.removeAll(where: { $0.id == schedule.id })
                }
            }
            self.dragOffset = 0
        }, onCancel: {
            self.dragOffset = 0
        })
    }
    
    @ViewBuilder private func arrow() -> some View {
        Image(systemName: "arrow.right")
            .font(.caption2)
    }
    
    @ViewBuilder private func superiorText(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.black.opacity(0.6))
            .lineLimit(1)
    }
    
    @ViewBuilder private func content() -> some View {
        VStack(alignment: HorizontalAlignment.leading) {
            HStack(spacing: 6) {
                Menu {
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Button {
                            do {
                                if let task = schedule as? TTask {
                                    try appData.setTaskPriority(task: task, to: priority)
                                } else if let project = schedule as? TProject {
                                    try appData.setProjectPriority(project: project, to: priority)
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            Text("\(priority.title)")
                        }
                    }
                } label: {
                    PriorityIcon(priority: schedule.priority)
                        .frame(width: titleTextHeight, height: titleTextHeight)
                }
                Menu {
                    ForEach(Status.allCases, id: \.self) { status in
                        Button {
                            do {
                                try appData.setStatus(schedule: schedule, to: status)
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            Text(status.title)
                            Image(systemName: status.systemName)
                        }
                    }
                } label: {
                    Image(systemName: schedule.status.systemName)
                        .foregroundStyle(schedule.status.imageColor)
                        .font(.callout)
                        .bold()
                }
                HStack(spacing: 4) {
                    NavigationLink {
                        DetailView(schedule: schedule, appData: $appData)
                    } label: {
                        Text(schedule.name)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                    }
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear
                                .onAppear {
                                    self.titleTextHeight = proxy.size.height
                                }
                                .onChange(of: proxy.size) {
                                    self.titleTextHeight = proxy.size.height
                                }
                        }
                    }
                    if let task = schedule as? TTask,
                       let superiorId = task.superiorId
                    {
                        if let superiorTask = appData.tasks.first(where: { $0.id == superiorId}) {
                            arrow()
                            NavigationLink {
                                DetailView(schedule: superiorTask, appData: $appData)
                            } label: {
                                superiorText(superiorTask.name)
                            }
                            
                        }
                    }
                }
                let tasks = appData.tasks.filter { schedule.taskIds.contains($0.id) }
                if !tasks.isEmpty {
                    TaskProgressBar(tasks: tasks)
                        .hideHeader()
                }
            }
            
            AdditionalInformationView(schedule: schedule)
        }
        .offset(x: max(0.0, offset))
    }
    
    public func isSelected(in schedules: Binding<[Schedulable]>) -> Self {
        var view = self
        view._selectedSchedules = schedules
        view.isSwipeEnabled = true
        
        return view
    }
}

#Preview {
    ContentView()
}

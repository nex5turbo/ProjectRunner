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
    init(schedule: Schedulable, appData: Binding<AppData>) {
        self.schedule = schedule
        self._appData = appData
    }
    
    @State private var titleTextHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    private var isNavigatable: Bool = false
    @AppStorage("timeline") private var shouldShowTimeline: Bool = false
    
    @State private var shouldShowSwipeContents: Bool = false
    @State private var sideButtonWidth: CGFloat = 1
    @State private var isDeleteConfirmPresented: Bool = false
    
    var body: some View {
        let offset: CGFloat = shouldShowSwipeContents ? sideButtonWidth + dragOffset : dragOffset
        ZStack {
            if isNavigatable {
                NavigationLink {
                    if let task = schedule as? TTask {
                        TaskDetailView(task: task, appData: $appData)
                    } else if let project = schedule as? TProject {
                        ProjectDetailView(project: project, appData: $appData)
                    }
                } label: {
                    Color.white
                }
            }
            
            VStack(alignment: HorizontalAlignment.leading) {
                HStack {
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
                    if isNavigatable {
                        NavigationLink {
                            if let task = schedule as? TTask {
                                TaskDetailView(task: task, appData: $appData)
                            } else if let project = schedule as? TProject {
                                ProjectDetailView(project: project, appData: $appData)
                            }
                        } label: {
                            Text(schedule.name)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.black)
                                .overlay {
                                    GeometryReader { proxy in
                                        Color.clear.task {
                                            self.titleTextHeight = proxy.size.height
                                        }
                                    }
                                }
                        }
                    } else {
                        Text(schedule.name)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.black)
                    }
                    let tasks = appData.tasks.filter { schedule.taskIds.contains($0.id) }
                    if !tasks.isEmpty {
                        TaskProgressBar(tasks: tasks)
                            .hideHeader()
                    }
                }
                
                AdditionalInformationView(schedule: schedule)
                
//                AnimatedTimeline(schedule: schedule, appData: $appData)
//                    .showTimeline(shouldShowTimeline)
//                    .padding(.top, shouldShowTimeline ? 8.0 : 0.0)
            }
            .offset(x: max(0.0, offset))
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
                    schedule.markColor.color.frame(width: (shouldShowSwipeContents ? 0 : 8) + max(0.0, offset))
                    Spacer()
                }
                HStack {
                    HStack(spacing: 16) {
                        Button {
                            self.isDeleteConfirmPresented = true
                        } label: {
                            Image(systemName: "trash.fill")
                        }
                        .foregroundStyle(schedule.markColor.textColor)
                        .confirmationDialog("", isPresented: $isDeleteConfirmPresented) {
                            Button("Delete", role: .destructive) {
                                do {
                                    try appData.delete(schedule: self.schedule)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                
                            }
                        } message: {
                            Text("Are you sure to delete?")
                        }

                        
                        NavigationLink {
                            if let task = schedule as? TTask {
                                TaskAddView(task: task, appData: $appData)
                            } else if let project = schedule as? TProject {
                                ProjectAddView(project: project, appData: $appData)
                            } else {
                                Text("Error Occured")
                            }
                        } label: {
                            Image(systemName: "pencil")
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
        .highPriorityGesture(DragGesture()
            .onChanged({ value in
                self.dragOffset = value.translation.width
            })
            .onEnded { value in
                if value.predictedEndTranslation.width >= self.sideButtonWidth {
                    self.shouldShowSwipeContents = true
                } else {
                    self.shouldShowSwipeContents = false
                }
                self.dragOffset = 0
            }
        )
    }
    
    public func navigatable() -> Self {
        var view = self
        view.isNavigatable = true
        return view
    }
}

#Preview {
    ContentView()
}

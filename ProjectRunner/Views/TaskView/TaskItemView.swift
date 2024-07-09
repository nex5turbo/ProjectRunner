//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct TaskItemView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("timeline") private var shouldShowTimeline = false
    let task: TTask
    @Binding var appData: AppData
    
    var isNavigatable: Bool = false
    
    var body: some View {
        Text("er")
//        ScheduleItemView(markColor: task.markColor) {
//            ZStack {
//                if isNavigatable {
//                    NavigationLink {
//                        TaskDetailView(task: task, appData: $appData)
//                    } label: {
//                        Color.white
//                    }
//                }
//                VStack(alignment: HorizontalAlignment.leading) {
//                    if isNavigatable {
//                        NavigationLink {
//                            TaskDetailView(task: task, appData: $appData)
//                        } label: {
//                            Text(task.name)
//                                .font(.title2)
//                                .bold()
//                                .foregroundStyle(.black)
//                        }
//                    } else {
//                        Text(task.name)
//                            .font(.title2)
//                            .bold()
//                    }
//                    AdditionalInformationView(schedule: task)
//                    AnimatedTimeline(schedule: task, appData: $appData)
//                        .showTimeline(shouldShowTimeline)
//                }
//            }
//        }
    }
    
    func navigatable() -> Self {
        var view = self
        view.isNavigatable = true
        return view
    }
}

#Preview {
    ContentView()
}

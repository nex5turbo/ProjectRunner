//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ProjectItemView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("timeline") private var shouldShowTimeline = false
    let project: TProject
    @Binding var appData: AppData
    var isNavigatable: Bool = false
    var body: some View {
        Text("er")
//        ScheduleItemView(markColor: project.markColor) {
//            ZStack {
//                if isNavigatable {
//                    NavigationLink {
//                        ProjectDetailView(project: project, appData: $appData)
//                    } label: {
//                        Color.white
//                    }
//                }
//                
//                VStack(alignment: HorizontalAlignment.leading) {
//                    if isNavigatable {
//                        NavigationLink {
//                            
//                        } label: {
//                            Text(project.name)
//                                .font(Font.title2)
//                                .bold()
//                                .foregroundStyle(.black)
//                        }
//                    } else {
//                        Text(project.name)
//                            .font(Font.title2)
//                            .bold()
//                    }
//                    let tasks = appData.tasks.filter { project.taskIds.contains($0.id) }
//                    TaskProgressBar(tasks: tasks)
//                    AdditionalInformationView(schedule: project)
//                    AnimatedTimeline(schedule: project, appData: $appData)
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
